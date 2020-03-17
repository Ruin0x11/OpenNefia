return {
  main_menu = {
    about = {
      credits = "クレジット",
      foobar_changelog = "Elona foobar 変更履歴",
      foobar_homepage = "Elona foobar ホームページ",
      license = "ライセンス",
      title = "About",
      vanilla_homepage = "本家ホームページ"
    },
    about_changelog = {
      title = "更新履歴"
    },
    continue = {
      delete = function(_1)
  return ("本当に%sを削除していいのかい？")
  :format(_1)
end,
      delete2 = function(_1)
  return ("本当の本当に%sを削除していいのかい？")
  :format(_1)
end,
      key_hint = "BackSpace [削除]  ",
      no_save = "No save files found",
      title = "冒険者の選択",
      which_save = "どの冒険を再開するんだい？"
    },
    incarnate = {
      no_gene = "No gene files found",
      title = "遺伝子の選択",
      which_gene = "どの遺伝子を引き継ぐ？"
    },
    mod_develop = {
      exist = function(_1)
  return ("MOD '%s' はすでに存在します")
  :format(_1)
end,
      invalid_id = function(_1)
  return ("'%s' は無効です。アルファベット、数字、アンダーバーのみ使用できます")
  :format(_1)
end,
      key_hint = "決定 [作成]",
      lets_create = "MODを作ってみよう。",
      no_template = "No template found",
      title = "MOD"
    },
    mod_list = {
      download = {
        failed = "MODリストのダウンロードに失敗しました。"
      },
      hint = {
        download = "[ダウンロード]",
        info = "[MODの情報]",
        installed = "[インストール済み]",
        toggle = "[有効/無効にする]"
      },
      info = {
        author = "作者",
        description = "説明文",
        id = "ID",
        name = "名前",
        title = "情報",
        version = "バージョン"
      },
      no_readme = "(READMEはありません)",
      title = {
        download = "MODのダウンロード",
        installed = "インストール済みのMOD"
      }
    },
    mods = {
      menu = {
        develop = "開発",
        list = "リスト"
      },
      title = "MOD"
    },
    title_menu = {
      about = "このゲームについて",
      restore = "冒険を再開する",
      exit = "終了",
      incarnate = "冒険者の引継ぎ",
      mods = "MOD",
      generate = "新しい冒険者を作成する",
      options = "設定の変更"
    }
  }
}