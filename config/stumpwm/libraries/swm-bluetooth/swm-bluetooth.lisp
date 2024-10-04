;;;; swm-bluetooth.lisp

;;; Copyright (C) 2024  Erik P Almaraz <erikalmaraz@fastmail.com>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;;

;;; References:
;;; 1. https://config.phundrak.com/stumpwm#bluetooth
;;; 2. TBD


(in-package :swm-bluetooth)

(defvar *bluetooth-command* "bluetoothctl"
  "Base command for interacting with bluetooth.")

;;; Utilities
(defun bluetooth-message (&rest message)
  (message (format nil "^2Bluetooth:^7 ~{~A~^ ~}" message)))

(defun bluetooth-make-command (&rest args)
  (format nil "~a ~{~A~^ ~}" *bluetooth-command* args))

(defmacro bluetooth-command (&rest args)
  `(run-shell-command (bluetooth-make-command ,@args) t))

(defmacro bluetooth-message-command (&rest args)
  `(bluetooth-message (bluetooth-command ,@args)))

;;; Bluetooth Devices
(defstruct (bluetooth-device
            (:constructor make-bluetooth-device (&key (address "") (name nil)))
            (:constructor make-bluetooth-device-from-command
                (&key (raw-name "")
                 &aux (address (second (re:split " " raw-name)))
                      (full-name (format nil "~{~A~^ ~}"
                                         (rest (rest (re:split " " raw-name))))))))
  address
  (full-name (progn (format nil "~{~A~^ ~}" name))))

(defun bluetooth-get-devices ()
  (let ((literal-devices (bluetooth-command "devices")))
    (mapcar (lambda (device)
              (make-bluetooth-device-from-command :raw-name device))
     (re:split "\\n" literal-devices))))


;;; Connect to a device
(defun bluetooth-connect-device (device)
  (progn
    (bluetooth-turn-on)
    (cond ((bluetooth-device-p device) ;; it is a bluetooth-device structure
           (bluetooth-message-command "connect"
                                      (bluetooth-device-address device)))
          ((stringp device) ;; assume it is a MAC address
           (bluetooth-message-command "connect" device))
          (t (message (format nil "Cannot work with device ~a" device))))))


;;; StumpWM Interface
(defcommand bluetooth-connect () ()
  "Connect to an established device."
  (sb-thread:make-thread
   (lambda ()
     (let* ((devices (bluetooth-get-devices))
            (choice  (second (select-from-menu
                              (current-screen)
                              (mapcar (lambda (device)
                                        `(,(bluetooth-device-full-name device)
                                          ,device))
                                      devices)))))
       (bluetooth-connect-device choice)))))

;;; Toggle Bluetooth on/off
(defcommand bluetooth-turn-on () ()
  "Turn on bluetooth."
  (bluetooth-message-command "power" "on"))

(defcommand bluetooth-turn-off () ()
  "Turn off bluetooth."
  (bluetooth-message-command "power" "off"))