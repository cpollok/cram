;;; Copyright (c) 2012, Gayane Kazhoyan <kazhoyan@in.tum.de>
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
;;;     * Neither the name of the Intelligent Autonomous Systems Group/
;;;       Technische Universitaet Muenchen nor the names of its contributors 
;;;       may be used to endorse or promote products derived from this software 
;;;       without specific prior written permission.
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

(in-package :btr-costmap)

(register-location-validation-function
 5 potential-field-costmap-pose-validator
 "The potential field cost-function that we use for spatial relations is too wide - 180
  degrees. Theoretically it is correct, but for practical use we need to make the angle
  narrower. At the smaller angles the solutions have the highest values, so we put a
  threshold on the solution values.")

(register-location-validation-function
 6 collision-pose-validator
 "If a location was generated for an item, then it is checked if the
  generated pose causes collisions of that object with other items,
  in which case the pose is rejected.")

(defun potential-field-costmap-pose-validator (desig pose)
  "If desig-props:for is specified it means we generated a costmap for a specific object.
   In that case a specific costmap spread angle might be needed for that object, i.e.
   a threshold on costmap values is specified for that object in the knowledge base."
  (if (typep pose 'cl-transforms:pose)
      (let ((for-prop-value (desig-prop-value desig :for)))
        (if for-prop-value
            (let* ((cm (location-costmap::get-cached-costmap desig))
                   (p (cl-transforms:origin pose)))
              (if cm
                  (let ((costmap-value (/ (get-map-value
                                           cm
                                           (cl-transforms:x p)
                                           (cl-transforms:y p))
                                          (location-costmap::get-cached-costmap-maxvalue cm))))
                    (with-vars-bound (?threshold)
                        (lazy-car
                         (prolog `(and
                                   (bullet-world ?w)
                                   (object-instance-name ,for-prop-value ?obj-name)
                                   (object-costmap-threshold ?w ?obj-name ?threshold))))
                      (sb-ext:gc :full t)
                      (if (is-var ?threshold)
                          :accept
                          (if (> costmap-value ?threshold)
                              :accept
                              :reject))))
                  :accept))
            :accept))
      :unknown))

(defun collision-pose-validator (desig pose)
  "Checks if desig has a property FOR. If so, checks if the object described by FOR is
   an item. If so, uses the prolog predicate desig-solution-not-in-collision."
  (if (typep pose 'cl-transforms:pose)
      (let ((for-prop-value (desig-prop-value desig :for)))
        (if (and for-prop-value
                 (prolog `(and
                           (object-instance-name ,for-prop-value ?object-name)
                           (item-type ?world ?object-name ?_))))
            (if (prolog `(desig-solution-not-in-collision ,desig ,for-prop-value ,pose))
                :accept
                :reject)
            :accept))
      :unknown))

