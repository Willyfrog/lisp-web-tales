(ql: quickload '("restas" "sexml"))

(restas:define-module #:blogdemo
    (:use #:cl #:restas))

(in-package #:blogdemo)

(sexml:with-compiletime-active-layers
    (sexml:standard-sexml sexml:xml-doctype)
  (sexml:support-dtd
   (merge-pathnames "html5.dtd" (asdf:system-source-directory "sexml"))
   :<))

(<:augment-with-doctype "html" "")

(defparameter *posts* nil)

;;; utility

(defun slug (string)
  (substitute #\- #\Space 
              (string-downcase (string-trim '(#\Space #\Tab #\Newline) 
                                            string))))
;;; templates
(defun html-frame (title body)
  (<:html
   (<:head (<:title title))
   (<:body
    (<:a :href (genurl 'home) (<:h1 title))
    body)))

(defun render-post (post)
  (list (<:div 
         (<:h2 (<:a :href (genurl 'post :id (position post *posts* 
                                                             :test #'equal))
                    (getf post :title)))
         (<:h3 (<:a :href (genurl 'author :id (getf post :author-id))
                    "By " (getf post :author)))
         (<:p (getf post :content)))
        (<:hr)))

(defun render-posts (posts)
  (mapcar #'render-post posts))

(defun blogpage (&optional (posts *posts*))
  (html-frame 
   "Restas Blogdemo" 
   (<:div 
    (<:a :href (genurl 'add) "Add a blog post")
    (<:hr)
    (render-posts posts))))

(defun add-post-form ()
  (html-frame
   "Restas Blogdemo"
   (<:form :action (genurl 'add/post) :method "post"
           "Author name:" (<:br)
           (<:input :type "text" :name "author")(<:br)
           "Title:" (<:br)
           (<:input :type "text" :name "title") (<:br)
           "Content:" (<:br)
           (<:textarea :name "content" :rows 15 :cols 80) (<:br)
           (<:input :type "submit" :value "Submit"))))

;;; Routes def
