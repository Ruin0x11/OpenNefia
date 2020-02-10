(local mac {})

(fn mac.require* [...]
  (local names (list))
  (local requires (list (sym :values)))
  (each [_ obj (ipairs [...])]
    (let [name (if (= (type obj) "table")
                   (. obj :name)
                   (string.match obj "%.?([^%.]+)$"))
          path (if (= (type obj) "table")
                   (. obj :path)
                   (tostring obj))]
      (table.insert names (sym name))
      (table.insert requires (list (sym :require) path))))
  (let [it (list (sym :local) names requires)]
    (print it)
    it)
  )

(fn mac.comment [...] nil)

(fn to-lua-case [sym]
  (string.gsub  (tostring sym) "-" "_"))

(local reify-table nil)
(fn reify-table [lst]
  (local result {})
  (each [_ form (ipairs lst)]
    (if (list? form)
        (let [k (. form 1)
              key (if (sym? k) (to-lua-case k) k)]
          (if (or (> (length form) 2) (list? (. form 2)))
              (do
                (if (= (tostring (. (. form 2) 1)) "unquote")
                      (tset result key (. (. form 2) 2))
                      (do
                          (table.remove form 1)
                        (tset result key (reify-table form)))))
              (let [value (. form 2)]
                (tset result key value))))
        (table.insert result form)))
  result)

(fn mac.definst [id ty ...]
  (local tbl (reify-table [...]))
  (tset tbl :_id (to-lua-case id))
  (tset tbl :_type (to-lua-case ty))
  (list (sym "data:add") tbl))

(fn mac.deflocale [props] (reify-table props))

(fn mac.defhandler [event desc args ...]
  (list (sym :Event.register) (tostring event) desc (table.append
                                                     (list (sym :fn) args)
                                                     (list ...))))

mac
