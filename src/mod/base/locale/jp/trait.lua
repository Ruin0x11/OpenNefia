return {
   trait = {
      anorexia = "あなたは拒食症だ",
      body_is_complicated = function(_1)
         return ("あなたは複雑な体をしている[速度-%s%]")
            :format(_1)
      end,
      ether_disease_grows = {
         fast = "あなたのエーテル病の進行は早い",
         slow = "あなたのエーテル病の進行は遅い"
      },
      incognito = "あなたは変装している",
      pregnant = "あなたは寄生されている",
      window = {
         ally = "仲間",
         already_maxed = "これ以上取得できない。",
         available_feats = "◆ 取得できるフィート",
         category = {
            etc = "その他",
            ether_disease = "ｴｰﾃﾙ病",
            feat = "フィート",
            mutation = "変異",
            race = "先天"
         },
         detail = "特徴の効果",
         enter = "決定 [フィート取得]",
         feats_and_traits = "◆ 特徴と体質",
         his_equipment = function(_1, _2)
            return ("%s装備は%s")
               :format(_1, _2)
         end,
         level = "段階",
         name = "特徴の名称",
         requirement = "条件不足",
         title = "特徴と体質",
         you_can_acquire = function(_1)
            return ("残り %s個のフィートを取得できる")
               :format(_1)
         end,
         your_trait = function(_1)
            return ("%sの特性")
               :format(_1)
         end
      }
   }
}
