;;;
;;; Copyright (c) 2009, Lorenz Moesenlechner <moesenle@cs.tum.edu>
;;; All rights reserved.
;;; 
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;; 
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of Willow Garage, Inc. nor the names of its
;;;       contributors may be used to endorse or promote products derived from
;;;       this software without specific prior written permission.
;;; 
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.
;;;

(in-package :json-prolog)

(defvar *finish-marker* nil)
(defvar *service-namespace* "/json_prolog")

(defvar *persistent-services* (make-hash-table :test 'equal))

(defun make-query-id ()
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:MAKE-QUERY-ID (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  (symbol-name (gensym (format nil "QUERY-~10,20$-" (ros-time)))))

(defun call-prolog-service (name type &rest request)
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:CALL-PROLOG-SERVICE (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  (let ((service (gethash name *persistent-services*)))
    (unless (and service (persistent-service-ok service))
      (setf (gethash name *persistent-services*)
            (make-instance 'persistent-service
              :service-name name
              :service-type type))))
  (apply #'call-persistent-service (gethash name *persistent-services*)
         request))

(defun prolog-result->bdgs (query-id result &key (lispify nil) (package *package*))
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:PROLOG-RESULT->BDGS (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  (unless (json_prolog_msgs-srv:ok result)
    (error 'simple-error
           :format-control "Prolog query failed: ~a."
           :format-arguments (list (json_prolog_msgs-srv:message result))))
  (lazy-list ()
    (cond (*finish-marker*
           (call-prolog-service (concatenate 'string *service-namespace* "/finish")
                                'json_prolog_msgs-srv:PrologFinish
                                :id query-id)
           nil)
          (t
           (let ((next-value
                   (call-prolog-service (concatenate 'string *service-namespace* "/next_solution")
                                'json_prolog_msgs-srv:PrologNextSolution
                                :id query-id)))
             (ecase (car (rassoc (json_prolog_msgs-srv:status next-value)
                                 (symbol-codes 'json_prolog_msgs-srv:<prolognextsolution-response>)))
               (:no_solution nil)
               (:wrong_id (error 'simple-error
                                 :format-control "We seem to have lost our query. ID invalid."))
               (:query_failed (error 'simple-error
                                     :format-control "Prolog query failed: ~a"
                                     :format-arguments (list (json_prolog_msgs-srv:solution next-value))))
               (:ok (cont (json-bdgs->prolog-bdgs (json_prolog_msgs-srv:solution next-value)
                                                  :lispify lispify
                                                  :package package)))))))))

(defun check-connection ()
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:CHECK-CONNECTION (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  "Returns T if the json_prolog could be found, otherwise NIL."
  (when (eql roslisp::*node-status* :running)
    (roslisp:wait-for-service
     (concatenate 'string *service-namespace* "/query")
     0.2)))

(defun prolog (exp &key (prologify t) (lispify nil) (package *package*))
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:PROLOG (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  (let ((query-id (make-query-id)))
    (prolog-result->bdgs
     query-id
     (call-prolog-service (concatenate 'string *service-namespace* "/query")
                          'json_prolog_msgs-srv:PrologQuery
                          :id query-id
                          :query (prolog->json exp :prologify prologify))
     :lispify lispify :package package)))

(defun prolog-1 (exp &key (prologify t) (lispify nil) (package *package*))
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:PROLOG-1 (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  "Like PROLOG but closes the query after the first solution."
  (let ((bdgs (prolog exp :prologify prologify :lispify lispify :package package)))
    (finish-query bdgs)))

(defun prolog-simple (query-str &key (lispify nil) (package *package*))
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:PROLOG-SIMPLE (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  "Takes a prolog expression (real prolog, not the lispy version) and
evaluates it."
  (let ((query-id (make-query-id)))
    (prolog-result->bdgs
     query-id
     (call-prolog-service (concatenate 'string *service-namespace* "/simple_query")
                          'json_prolog_msgs-srv:PrologQuery
                          :id query-id
                          :query query-str)
     :lispify lispify :package package)))

(defun prolog-simple-1 (query-str &key (lispify nil) (package *package*))
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:PROLOG-SIMPLE-1 (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  "Like PROLOG-SIMPLE but closes the query after the first solution."
  (let ((bdgs (prolog-simple query-str :lispify lispify :package package)))
    (finish-query bdgs)))
  
(defun finish-query (result)
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:FINISH-QUERY (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  (let ((*finish-marker* t))
    (lazy-cdr (last result))
    result))

(defun wait-for-prolog-service (&optional timeout)
  (cut:deprecate "Use of deprecated form CL-JSON-PL-CLIENT:WAIT-FOR-PROLOG-SERVICE (CRAM-HIGHLEVEL). Please use the equivalent in CRAM-JSON-PROLOG (CRAM-BRIDGE).")
  (wait-for-service
   (concatenate 'string *service-namespace* "/query")
   timeout))
