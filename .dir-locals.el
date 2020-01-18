((nil . ((eval . (let ((cmd
                        (if (eq system-type 'windows-nt)
                            "cd z:/build/elona-next/src & taskkill /IM love.exe /f & C:\\Users\\kuzuki\\build\\megasource\\build\\love\\Debug\\love.exe --console ."
                          "elona-next")))
                   (setq projectile-project-compilation-cmd cmd)
                   (setq projectile-project-run-cmd cmd))))
      ))
