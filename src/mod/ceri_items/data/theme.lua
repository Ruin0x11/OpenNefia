-- ├── ffhp
-- │   ├── item_133.bmp

-- ├── other
-- │   ├── item_354.bmp
-- │   ├── item_429.bmp
-- │   ├── item_470.bmp
-- │   ├── item_471.bmp
-- │   ├── 宝石で飾られた宝箱っぽい.bmp
-- │   ├── 巻物無地.bmp
-- │   ├── 弁当っぽい.bmp
-- │   └── 魔法書.bmp

data:add {
   _type = "base.theme",
   _id = "ceri_items",

   overrides = {
      ["base.chip"] = {
         ["elona.item_map"] = {
            image = "mod/ceri_items/graphic/ffhp/item_133.bmp"
         },
         ["elona.item_potion"] = {
            image = "mod/ceri_items/graphic/other/item_354.bmp"
         },
         ["elona.item_spellbook"] = {
            image = "mod/ceri_items/graphic/other/item_429.bmp"
         },
         ["elona.item_scroll"] = {
            image = "mod/ceri_items/graphic/other/item_470.bmp"
         },
         ["elona.item_rod"] = {
            image = "mod/ceri_items/graphic/other/item_471.bmp"
         }
      },

      ["ffhp.item_ex_mapping"] = {
         ["ffhp.ex_potion_540"] = {
            chip_on_identify = "ceri_items.ex_potion_540",
         },
         ["ffhp.ex_potion_548"] = {
            chip_on_identify = "ceri_items.ex_potion_548",
         },
         ["ffhp.ex_spellbook_615"] = {
            chip_on_identify = "ceri_items.ex_spellbook_615",
         },
         ["ffhp.ex_scroll_674"] = {
            chip_on_identify = "ceri_items.ex_scroll_674",
         },
         ["ffhp.ex_potion_552"] = {
            chip_on_identify = "ceri_items.ex_potion_552",
         },
         ["ffhp.ex_spellbook_639"] = {
            chip_on_identify = "ceri_items.ex_spellbook_639",
         },
         ["ffhp.ex_rod_586"] = {
            chip_on_identify = "ceri_items.ex_rod_586",
         },
         ["ffhp.ex_scroll_666"] = {
            chip_on_identify = "ceri_items.ex_scroll_666",
         },
         ["ffhp.ex_potion_533"] = {
            chip_on_identify = "ceri_items.ex_potion_533",
         },
         ["ffhp.ex_potion_529"] = {
            chip_on_identify = "ceri_items.ex_potion_529",
         },
         ["ffhp.ex_spellbook_612"] = {
            chip_on_identify = "ceri_items.ex_spellbook_612",
         },
         ["ffhp.ex_ffhp_686"] = {
            chip_on_identify = "ceri_items.ex_ffhp_686",
         },
         ["ffhp.ex_spellbook_614"] = {
            chip_on_identify = "ceri_items.ex_spellbook_614",
         },
         ["ffhp.ex_potion_547"] = {
            chip_on_identify = "ceri_items.ex_potion_547",
         },
         ["ffhp.ex_scroll_657"] = {
            chip_on_identify = "ceri_items.ex_scroll_657",
         },
         ["ffhp.ex_potion_551"] = {
            chip_on_identify = "ceri_items.ex_potion_551",
         },
         ["ffhp.ex_spellbook_606"] = {
            chip_on_identify = "ceri_items.ex_spellbook_606",
         },
         ["ffhp.ex_scroll_649"] = {
            chip_on_identify = "ceri_items.ex_scroll_649",
         },
         ["ffhp.ex_spellbook_646"] = {
            chip_on_identify = "ceri_items.ex_spellbook_646",
         },
         ["ffhp.ex_potion_520"] = {
            chip_on_identify = "ceri_items.ex_potion_520",
         },
         ["ffhp.ex_spellbook_623"] = {
            chip_on_identify = "ceri_items.ex_spellbook_623",
         },
         ["ffhp.ex_potion_528"] = {
            chip_on_identify = "ceri_items.ex_potion_528",
         },
         ["ffhp.ex_ffhp_685"] = {
            chip_on_identify = "ceri_items.ex_ffhp_685",
         },
         ["ffhp.ex_potion_532"] = {
            chip_on_identify = "ceri_items.ex_potion_532",
         },
         ["ffhp.ex_spellbook_609"] = {
            chip_on_identify = "ceri_items.ex_spellbook_609",
         },
         ["ffhp.ex_scroll_668"] = {
            chip_on_identify = "ceri_items.ex_scroll_668",
         },
         ["ffhp.ex_spellbook_625"] = {
            chip_on_identify = "ceri_items.ex_spellbook_625",
         },
         ["ffhp.ex_scroll_676"] = {
            chip_on_identify = "ceri_items.ex_scroll_676",
         },
         ["ffhp.ex_scroll_652"] = {
            chip_on_identify = "ceri_items.ex_scroll_652",
         },
         ["ffhp.ex_ffhp_688"] = {
            chip_on_identify = "ceri_items.ex_ffhp_688",
         },
         ["ffhp.ex_spellbook_595"] = {
            chip_on_identify = "ceri_items.ex_spellbook_595",
         },
         ["ffhp.ex_rod_577"] = {
            chip_on_identify = "ceri_items.ex_rod_577",
         },
         ["ffhp.ex_ffhp_684"] = {
            chip_on_identify = "ceri_items.ex_ffhp_684",
         },
         ["ffhp.ex_scroll_681"] = {
            chip_on_identify = "ceri_items.ex_scroll_681",
         },
         ["ffhp.ex_scroll_689"] = {
            chip_on_identify = "ceri_items.ex_scroll_689",
         },
         ["ffhp.ex_rod_565"] = {
            chip_on_identify = "ceri_items.ex_rod_565",
         },
         ["ffhp.ex_spellbook_592"] = {
            chip_on_identify = "ceri_items.ex_spellbook_592",
         },
         ["ffhp.ex_spellbook_624"] = {
            chip_on_identify = "ceri_items.ex_spellbook_624",
         },
         ["ffhp.ex_scroll_675"] = {
            chip_on_identify = "ceri_items.ex_scroll_675",
         },
         ["ffhp.ex_spellbook_600"] = {
            chip_on_identify = "ceri_items.ex_spellbook_600",
         },
         ["ffhp.ex_scroll_659"] = {
            chip_on_identify = "ceri_items.ex_scroll_659",
         },
         ["ffhp.ex_spellbook_640"] = {
            chip_on_identify = "ceri_items.ex_spellbook_640",
         },
         ["ffhp.ex_spellbook_641"] = {
            chip_on_identify = "ceri_items.ex_spellbook_641",
         },
         ["ffhp.ex_rod_570"] = {
            chip_on_identify = "ceri_items.ex_rod_570",
         },
         ["ffhp.ex_rod_582"] = {
            chip_on_identify = "ceri_items.ex_rod_582",
         },
         ["ffhp.ex_scroll_680"] = {
            chip_on_identify = "ceri_items.ex_scroll_680",
         },
         ["ffhp.ex_spellbook_619"] = {
            chip_on_identify = "ceri_items.ex_spellbook_619",
         },
         ["ffhp.ex_scroll_670"] = {
            chip_on_identify = "ceri_items.ex_scroll_670",
         },
         ["ffhp.ex_potion_544"] = {
            chip_on_identify = "ceri_items.ex_potion_544",
         },
         ["ffhp.ex_rod_576"] = {
            chip_on_identify = "ceri_items.ex_rod_576",
         },
         ["ffhp.ex_potion_556"] = {
            chip_on_identify = "ceri_items.ex_potion_556",
         },
         ["ffhp.ex_scroll_654"] = {
            chip_on_identify = "ceri_items.ex_scroll_654",
         },
         ["ffhp.ex_scroll_662"] = {
            chip_on_identify = "ceri_items.ex_scroll_662",
         },
         ["ffhp.ex_spellbook_635"] = {
            chip_on_identify = "ceri_items.ex_spellbook_635",
         },
         ["ffhp.ex_rod_573"] = {
            chip_on_identify = "ceri_items.ex_rod_573",
         },
         ["ffhp.ex_potion_537"] = {
            chip_on_identify = "ceri_items.ex_potion_537",
         },
         ["ffhp.ex_rod_569"] = {
            chip_on_identify = "ceri_items.ex_rod_569",
         },
         ["ffhp.ex_spellbook_597"] = {
            chip_on_identify = "ceri_items.ex_spellbook_597",
         },
         ["ffhp.ex_potion_525"] = {
            chip_on_identify = "ceri_items.ex_potion_525",
         },
         ["ffhp.ex_rod_571"] = {
            chip_on_identify = "ceri_items.ex_rod_571",
         },
         ["ffhp.ex_rod_567"] = {
            chip_on_identify = "ceri_items.ex_rod_567",
         },
         ["ffhp.ex_spellbook_632"] = {
            chip_on_identify = "ceri_items.ex_spellbook_632",
         },
         ["ffhp.ex_rod_578"] = {
            chip_on_identify = "ceri_items.ex_rod_578",
         },
         ["ffhp.ex_ffhp_692"] = {
            chip_on_identify = "ceri_items.ex_ffhp_692",
         },
         ["ffhp.ex_scroll_653"] = {
            chip_on_identify = "ceri_items.ex_scroll_653",
         },
         ["ffhp.ex_scroll_661"] = {
            chip_on_identify = "ceri_items.ex_scroll_661",
         },
         ["ffhp.ex_scroll_669"] = {
            chip_on_identify = "ceri_items.ex_scroll_669",
         },
         ["ffhp.ex_potion_555"] = {
            chip_on_identify = "ceri_items.ex_potion_555",
         },
         ["ffhp.ex_spellbook_610"] = {
            chip_on_identify = "ceri_items.ex_spellbook_610",
         },
         ["ffhp.ex_spellbook_626"] = {
            chip_on_identify = "ceri_items.ex_spellbook_626",
         },
         ["ffhp.ex_spellbook_603"] = {
            chip_on_identify = "ceri_items.ex_spellbook_603",
         },
         ["ffhp.ex_spellbook_611"] = {
            chip_on_identify = "ceri_items.ex_spellbook_611",
         },
         ["ffhp.ex_rod_572"] = {
            chip_on_identify = "ceri_items.ex_rod_572",
         },
         ["ffhp.ex_spellbook_596"] = {
            chip_on_identify = "ceri_items.ex_spellbook_596",
         },
         ["ffhp.ex_potion_524"] = {
            chip_on_identify = "ceri_items.ex_potion_524",
         },
         ["ffhp.ex_spellbook_643"] = {
            chip_on_identify = "ceri_items.ex_spellbook_643",
         },
         ["ffhp.ex_potion_536"] = {
            chip_on_identify = "ceri_items.ex_potion_536",
         },
         ["ffhp.ex_spellbook_638"] = {
            chip_on_identify = "ceri_items.ex_spellbook_638",
         },
         ["ffhp.ex_spellbook_637"] = {
            chip_on_identify = "ceri_items.ex_spellbook_637",
         },
         ["ffhp.ex_spellbook_636"] = {
            chip_on_identify = "ceri_items.ex_spellbook_636",
         },
         ["ffhp.ex_spellbook_634"] = {
            chip_on_identify = "ceri_items.ex_spellbook_634",
         },
         ["ffhp.ex_spellbook_633"] = {
            chip_on_identify = "ceri_items.ex_spellbook_633",
         },
         ["ffhp.ex_spellbook_631"] = {
            chip_on_identify = "ceri_items.ex_spellbook_631",
         },
         ["ffhp.ex_spellbook_630"] = {
            chip_on_identify = "ceri_items.ex_spellbook_630",
         },
         ["ffhp.ex_spellbook_629"] = {
            chip_on_identify = "ceri_items.ex_spellbook_629",
         },
         ["ffhp.ex_spellbook_627"] = {
            chip_on_identify = "ceri_items.ex_spellbook_627",
         },
         ["ffhp.ex_spellbook_622"] = {
            chip_on_identify = "ceri_items.ex_spellbook_622",
         },
         ["ffhp.ex_spellbook_621"] = {
            chip_on_identify = "ceri_items.ex_spellbook_621",
         },
         ["ffhp.ex_spellbook_618"] = {
            chip_on_identify = "ceri_items.ex_spellbook_618",
         },
         ["ffhp.ex_spellbook_617"] = {
            chip_on_identify = "ceri_items.ex_spellbook_617",
         },
         ["ffhp.ex_spellbook_616"] = {
            chip_on_identify = "ceri_items.ex_spellbook_616",
         },
         ["ffhp.ex_spellbook_613"] = {
            chip_on_identify = "ceri_items.ex_spellbook_613",
         },
         ["ffhp.ex_spellbook_608"] = {
            chip_on_identify = "ceri_items.ex_spellbook_608",
         },
         ["ffhp.ex_spellbook_607"] = {
            chip_on_identify = "ceri_items.ex_spellbook_607",
         },
         ["ffhp.ex_spellbook_601"] = {
            chip_on_identify = "ceri_items.ex_spellbook_601",
         },
         ["ffhp.ex_spellbook_598"] = {
            chip_on_identify = "ceri_items.ex_spellbook_598",
         },
         ["ffhp.ex_spellbook_594"] = {
            chip_on_identify = "ceri_items.ex_spellbook_594",
         },
         ["ffhp.ex_potion_550"] = {
            chip_on_identify = "ceri_items.ex_potion_550",
         },
         ["ffhp.ex_spellbook_593"] = {
            chip_on_identify = "ceri_items.ex_spellbook_593",
         },
         ["ffhp.ex_spellbook_589"] = {
            chip_on_identify = "ceri_items.ex_spellbook_589",
         },
         ["ffhp.ex_scroll_682"] = {
            chip_on_identify = "ceri_items.ex_scroll_682",
         },
         ["ffhp.ex_rod_584"] = {
            chip_on_identify = "ceri_items.ex_rod_584",
         },
         ["ffhp.ex_scroll_679"] = {
            chip_on_identify = "ceri_items.ex_scroll_679",
         },
         ["ffhp.ex_scroll_678"] = {
            chip_on_identify = "ceri_items.ex_scroll_678",
         },
         ["ffhp.ex_scroll_677"] = {
            chip_on_identify = "ceri_items.ex_scroll_677",
         },
         ["ffhp.ex_scroll_673"] = {
            chip_on_identify = "ceri_items.ex_scroll_673",
         },
         ["ffhp.ex_scroll_672"] = {
            chip_on_identify = "ceri_items.ex_scroll_672",
         },
         ["ffhp.ex_scroll_667"] = {
            chip_on_identify = "ceri_items.ex_scroll_667",
         },
         ["ffhp.ex_scroll_665"] = {
            chip_on_identify = "ceri_items.ex_scroll_665",
         },
         ["ffhp.ex_spellbook_605"] = {
            chip_on_identify = "ceri_items.ex_spellbook_605",
         },
         ["ffhp.ex_scroll_663"] = {
            chip_on_identify = "ceri_items.ex_scroll_663",
         },
         ["ffhp.ex_scroll_660"] = {
            chip_on_identify = "ceri_items.ex_scroll_660",
         },
         ["ffhp.ex_scroll_658"] = {
            chip_on_identify = "ceri_items.ex_scroll_658",
         },
         ["ffhp.ex_scroll_651"] = {
            chip_on_identify = "ceri_items.ex_scroll_651",
         },
         ["ffhp.ex_scroll_650"] = {
            chip_on_identify = "ceri_items.ex_scroll_650",
         },
         ["ffhp.ex_potion_539"] = {
            chip_on_identify = "ceri_items.ex_potion_539",
         },
         ["ffhp.ex_rod_585"] = {
            chip_on_identify = "ceri_items.ex_rod_585",
         },
         ["ffhp.ex_rod_583"] = {
            chip_on_identify = "ceri_items.ex_rod_583",
         },
         ["ffhp.ex_rod_581"] = {
            chip_on_identify = "ceri_items.ex_rod_581",
         },
         ["ffhp.ex_rod_580"] = {
            chip_on_identify = "ceri_items.ex_rod_580",
         },
         ["ffhp.ex_rod_579"] = {
            chip_on_identify = "ceri_items.ex_rod_579",
         },
         ["ffhp.ex_rod_575"] = {
            chip_on_identify = "ceri_items.ex_rod_575",
         },
         ["ffhp.ex_rod_574"] = {
            chip_on_identify = "ceri_items.ex_rod_574",
         },
         ["ffhp.ex_scroll_664"] = {
            chip_on_identify = "ceri_items.ex_scroll_664",
         },
         ["ffhp.ex_rod_564"] = {
            chip_on_identify = "ceri_items.ex_rod_564",
         },
         ["ffhp.ex_rod_566"] = {
            chip_on_identify = "ceri_items.ex_rod_566",
         },
         ["ffhp.ex_rod_562"] = {
            chip_on_identify = "ceri_items.ex_rod_562",
         },
         ["ffhp.ex_rod_560"] = {
            chip_on_identify = "ceri_items.ex_rod_560",
         },
         ["ffhp.ex_potion_554"] = {
            chip_on_identify = "ceri_items.ex_potion_554",
         },
         ["ffhp.ex_potion_553"] = {
            chip_on_identify = "ceri_items.ex_potion_553",
         },
         ["ffhp.ex_potion_549"] = {
            chip_on_identify = "ceri_items.ex_potion_549",
         },
         ["ffhp.ex_potion_543"] = {
            chip_on_identify = "ceri_items.ex_potion_543",
         },
         ["ffhp.ex_potion_542"] = {
            chip_on_identify = "ceri_items.ex_potion_542",
         },
         ["ffhp.ex_potion_541"] = {
            chip_on_identify = "ceri_items.ex_potion_541",
         },
         ["ffhp.ex_scroll_648"] = {
            chip_on_identify = "ceri_items.ex_scroll_648",
         },
         ["ffhp.ex_potion_546"] = {
            chip_on_identify = "ceri_items.ex_potion_546",
         },
         ["ffhp.ex_spellbook_645"] = {
            chip_on_identify = "ceri_items.ex_spellbook_645",
         },
         ["ffhp.ex_potion_535"] = {
            chip_on_identify = "ceri_items.ex_potion_535",
         },
         ["ffhp.ex_potion_534"] = {
            chip_on_identify = "ceri_items.ex_potion_534",
         },
         ["ffhp.ex_potion_531"] = {
            chip_on_identify = "ceri_items.ex_potion_531",
         },
         ["ffhp.ex_potion_527"] = {
            chip_on_identify = "ceri_items.ex_potion_527",
         },
         ["ffhp.ex_potion_523"] = {
            chip_on_identify = "ceri_items.ex_potion_523",
         },
         ["ffhp.ex_potion_522"] = {
            chip_on_identify = "ceri_items.ex_potion_522",
         },
         ["ffhp.ex_potion_521"] = {
            chip_on_identify = "ceri_items.ex_potion_521",
         },
         ["ffhp.ex_ffhp_693"] = {
            chip_on_identify = "ceri_items.ex_ffhp_693",
         },
         ["ffhp.ex_ffhp_691"] = {
            chip_on_identify = "ceri_items.ex_ffhp_691",
         },
         ["ffhp.ex_ffhp_690"] = {
            chip_on_identify = "ceri_items.ex_ffhp_690",
         },
         ["ffhp.ex_ffhp_687"] = {
            chip_on_identify = "ceri_items.ex_ffhp_687",
         },
         ["ffhp.ex_ffhp_587"] = {
            chip_on_identify = "ceri_items.ex_ffhp_587",
         },
         ["ffhp.ex_ffhp_558"] = {
            chip_on_identify = "ceri_items.ex_ffhp_558",
         },
         ["ffhp.ex_scroll_656"] = {
            chip_on_identify = "ceri_items.ex_scroll_656",
         },
         ["ffhp.ex_spellbook_599"] = {
            chip_on_identify = "ceri_items.ex_spellbook_599",
         },
         ["ffhp.ex_ffhp_559"] = {
            chip_on_identify = "ceri_items.ex_ffhp_559",
         },
         ["ffhp.ex_rod_563"] = {
            chip_on_identify = "ceri_items.ex_rod_563",
         },
         ["ffhp.ex_spellbook_602"] = {
            chip_on_identify = "ceri_items.ex_spellbook_602",
         },
         ["ffhp.ex_rod_561"] = {
            chip_on_identify = "ceri_items.ex_rod_561",
         },
         ["ffhp.ex_spellbook_642"] = {
            chip_on_identify = "ceri_items.ex_spellbook_642",
         },
         ["ffhp.ex_spellbook_604"] = {
            chip_on_identify = "ceri_items.ex_spellbook_604",
         },
         ["ffhp.ex_potion_557"] = {
            chip_on_identify = "ceri_items.ex_potion_557",
         },
         ["ffhp.ex_spellbook_628"] = {
            chip_on_identify = "ceri_items.ex_spellbook_628",
         },
         ["ffhp.ex_rod_568"] = {
            chip_on_identify = "ceri_items.ex_rod_568",
         },
         ["ffhp.ex_scroll_671"] = {
            chip_on_identify = "ceri_items.ex_scroll_671",
         },
         ["ffhp.ex_scroll_647"] = {
            chip_on_identify = "ceri_items.ex_scroll_647",
         },
         ["ffhp.ex_spellbook_644"] = {
            chip_on_identify = "ceri_items.ex_spellbook_644",
         },
         ["ffhp.ex_potion_545"] = {
            chip_on_identify = "ceri_items.ex_potion_545",
         },
         ["ffhp.ex_scroll_655"] = {
            chip_on_identify = "ceri_items.ex_scroll_655",
         },
         ["ffhp.ex_spellbook_620"] = {
            chip_on_identify = "ceri_items.ex_spellbook_620",
         },
         ["ffhp.ex_potion_530"] = {
            chip_on_identify = "ceri_items.ex_potion_530",
         },
         ["ffhp.ex_potion_538"] = {
            chip_on_identify = "ceri_items.ex_potion_538",
         },
         ["ffhp.ex_spellbook_590"] = {
            chip_on_identify = "ceri_items.ex_spellbook_590",
         },
         ["ffhp.ex_potion_526"] = {
            chip_on_identify = "ceri_items.ex_potion_526",
         },
         ["ffhp.ex_ffhp_683"] = {
            chip_on_identify = "ceri_items.ex_ffhp_683",
         },
         ["ffhp.ex_spellbook_591"] = {
            chip_on_identify = "ceri_items.ex_spellbook_591",
         }
      }
   }
}
