;;;
;;; Copyright (c) 2015, Gayane Kazhoyan <kazhoyan@cs.uni-bremen.de>
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
;;;     * Neither the name of the Institute for Artificial Intelligence/
;;;       Universitaet Bremen nor the names of its contributors may be used to
;;;       endorse or promote products derived from this software without
;;;       specific prior written permission.
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

(in-package :cram-plan-occasions-events)

(def-fact-group occasions (object-in-hand object-placed-at object-picked object-put
                                          loc looking-at arms-parked
                                          container-state torso-at arms-positioned
                                          ees-at looking-at robot-loc)
  (<- (object-in-hand ?object ?hand ?grasp ?link)
    (fail))
  (<- (object-in-hand ?object ?hand ?grasp)
    (fail))
  (<- (object-in-hand ?object ?hand)
    (fail))
  (<- (object-in-hand ?object)
    (fail))

  (<- (object-placed-at ?object ?location)
    (fail))

  (<- (object-picked ?object)
    (fail))

  (<- (object-put ?object)
    (fail))

  (<- (loc ?robot-or-object ?location)
    (fail))

  (<- (robot-loc ?location)
    (fail))

  (<- (looking-at ?location)
    (fail))

  (<- (arms-parked)
    (fail))

  (<- (container-state ?container-object-designator ?joint-state)
    (fail))

  (<- (torso-at ?joint-state)
    (fail))

  (<- (torso-at ?joint-state ?delta)
    (fail))

  (<- (arms-positioned ?left-configuration ?right-configuration)
    (fail))

  (<- (arms-positioned ?left-configuration ?right-configuration ?delta)
    (fail))

  (<- (ees-at ?left-poses ?right-poses)
    (fail))

  (<- (ees-at ?left-poses ?right-poses ?delta-pos ?delta-rot)
    (fail))

  (<- (looking-at ?target)
    (fail))

  (<- (looking-at ?target ?delta)
    (fail)))
