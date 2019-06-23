return interface("IPaged",
                 {
                    select_page = "function",
                    next_page = "function",
                    previous_page = "function",
                    page = "number",
                    page_max = "number",
                    page_size = "number",
                    changed_page = "boolean",
                 })
