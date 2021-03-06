local area = {
   elona = {
      vernis = {
         "Welcome to Vernis!",
         "The mines around Vernis have brought a lot of money into our small community.  We are thriving thanks to the mines!",
         "Vernis may just be a coal mining town, but we have a long and notable history.",
         "If I were you, I wouldn't dare play the piano in the bar while Loyter is hanging out in there.  Don't say I didn't warn you.",
         "We're caught in the crossfire of the war between the Yerles and the Eulderna for some time now.",
         "Rumor has it that something of great value has been found in Lesimas.",
         "It seems there is a way to obtain new skills. See the trainer to the east of the town center.",
         "Be careful about carrying too much stuff.  You should sell off anything you don't actually need.",
         "That weirdo near the graveyard? Don't pay any attention to that bum. He's a hopeless junkie and I'm pretty sure he's an alcoholic too.",
         "Miches is nuts about stuffed animals.  She's completely obsessed with collecting them.",
         "The road to the east leads to the capital city of Palmia.",
         "You could bounce a quarter off of Shena's ass.  How does she stay in such great shape?",
         "We've had a lot of trouble with thieves recently.",
         "The people in that live in the Cyber Dome are so strange.  What a bunch of freaks!",
         "Vernis is the only known source of coal in the entirety of North Tyris.  We're making a killing.",
         "You're going to Palmia?  Just follow the road to the east.",
         "Everyone loves Shena's ass."
      },
      port_kapul = {
         "Ah, there's nothing like the salty smell of the sea breeze.",
         "I love to watch the brutal fights in the pet arena.  You have to be careful though, sometimes audience members catch a stray bullet or get hit by careless dragons.  But you know, the risk is part of the thrill.",
         "Raphael is the enemy of all women.",
         "If you want the best training a fighter can have, you should check out the fighter's guild under the arena office.",
         "The price of seafood cargo is very high farther inland. ",
         "I wonder how you get into that Pyramid north of town.  I have heard of people trying to go there, but none of them ever come back.",
         "I hear that a lot of the seediest and creepiest people head to Derphy.  I'm not sure where that place is, but we seem to get more than our fair share of thieves and vagabonds, so maybe it's not that far from here."
      },
      yowyn = {
         "This village is called Yowyn. ",
         "The horses sold here are the finest in the land.",
         "We always seem to be short-handed during the harvest season.  I'm sure everyone in town would be glad to have you lend a hand.",
         "Sometimes we see known outlaws heading to the west after they raid our farms or kill our cattle.  I wonder if something is out there.",
         "Head east out of town, and follow the road north to reach the capital of the Kingdom of Palmia.  Be careful around that old fortress though, it's a strange place.  I've heard sometimes people that go near that place are gunned down by ancient machines that survived from Eyth Terre.",
         "The elder always talks about an old run down castle to the southwest.  That old bag is always making up crazy stories.",
         "Yowyn's economy is pretty small, but we do make excellent caskets.  Sometimes the nobles from Palmia send their squires and servants down here to buy them.",
         "The air is so fresh and lively here in the countryside.  I wouldn't give this up for anything.%END",
      },
      derphy = {
         "Welcome to Derphy, a rotten hive of scum and villainy.",
         "Noel is crazy.  She'd bite the head off of a kitten if she had the chance.  She kills things and spreads chaos for the hell of it.  I don't mind a thief, but she's a bit over the top.",
         "A lot of thieves hang out here.  They have a hideout under the casino but they won't just let you in.",
         "Slavery is a very lucrative business.  Many people claim it's evil, but even mighty Palmia's economy would disintegrate if they didn't have any slaves to work their fields.",
         "Nothing beats a bloody match at the arena.  If you want to impress the crowd then give them lots of drama and blood.",
         "Derphy has no city guards, so we can do whatever we want!"
      },
      palmia = {
         "Palmia is huge.  I got lost in this town all the time.  It's really hard to find other people sometimes.",
         "I wonder what's wrong with Mia, she's so weird.  I wish she'd just learn how to talk properly, that'd help a lot.",
         "I can't make out anything that Mia says.",
         "Welcome to the capital of Palmia!  Our kingdom is old and very prosperous.",
         "King Xabi and Queen Stersha are a beautiful couple.",
         "One of our special products here are toys that the nobility often buy for their children.  There are machines in the center of town that sell them, if you can get some coins maybe you can get some awesome toys out of them too.",
         "The etherwinds have been getting strong and more dangerous over the last fifty years.  My grandfather always tells me about how weak they used to be.  If they grow much stronger we might be forced to abandon our homes.",
         "My friend told me there is an ancient fortress to the north.  I wonder if that's true.",
         "We have a lot of parties in Palmia.  The nobility will throw money at any excuse for a drunken celebration."
      },
      noyel = {
         "It's colder than death's pecker hanging in a well.  But, y'know, welcome to Noyel.",
         "The snow never goes away, but we still have to shovel it so we can get around.",
         "Have you seen that giant near the church?  I heard his name is Ebon.",
         "You can confess your sins at the church.  I can't think of a better way to be forgiven for your crimes.",
         "I'm freezing.  I can't feel my fingers.",
         "A while back I saw a small house south of Noyel.  It looked like some sort of workshop.",
         "Who would build a city here?  And why did I have to be so unfortunate as to be born here?"
      },
      lumiest = {
         "Lumiest is a city of great culture and art.  Welcome to our fine city.",
         "I heard there's a town famous for hot springs somewhere.",
         "Here in Lumiest, you can go fishing anywhere you like.  The schools of fish are huge and they never seem to get any smaller.  I wouldn't mind a hamburger from time to time though.",
         "I could talk about painting for hours.",
         "This is where the mage's guild keeps their libraries.  It's the only place in all of North Tyris where you can check out books on even the most obscure spells.",
         "They say something horrible lives in the sewers.  It smells horrific though, so I'd never go down there."
      },

      shelter = {
         "I'm so bored!",
         "When will this awful weather end?",
         "I hope the weather will recover quickly.",
         "This is about as exciting as a bag of broken rocks.",
         "This shelter was built using contributions by everyone in town.",
         "I appreciate the fact that this shelter is here, otherwise we'd never survive the etherwinds.",
         "We've got a lot of time in here.  We often have to stay in here for days.  I think more than half of our pregnancies begin in here.",
         "This is kind of exciting!",
         "We've got plenty of food stocked up.  We could stay in this place for months if we had to."
      },
   }
}

local random = {
   default = {
      "Scut stands for it's cute.",
      "I've got nothing to do.",
      function(npc, player, params)
         return ("%s? I've never heard of you.")
            :format(player.title)
      end,
      function(npc, player, params)
         return ("%s! You say you ARE %s?! ...nope, I've never heard of that. What is it?")
            :format(player.title, player.title)
      end,
      function(npc, player, params)
         return ("Hey aren't you the sparkling queer?  No?  The vigilant rainbow?  No?  Then what's your callsign?  %s?  That's a stupid name.")
            :format(player.title)
      end,
      "Some say the Vindale forest is the source of the etherwind.  I guess it's not impossible but it seems a bit silly.",
      "Our lives would be meaningless without the gods.",
      "The land of North Tyris has countless ruins and dungeons on it.  They are part of a long lost civilization we call Nefia.",
      "I'm so bored!",
      "You're an adventurer right? Got any news from afar?",
      "Nothing beats a good old crim ale after work.",
      "Cats... why are they so cute?",
      "What are you looking at?",
      "It is rumored that the prince of Zanan is planning a massive attack on the Vindale forests.",
      "The ether plague spreads from land to land. It started in the Vindale forest and brought ruin upon the eastern country of Karune. Fortunately, the great central ocean has, to some extent, been protecting us from the winds. I can't imagine any of the  countries in North Tyris would have survived that disaster.",
      "Ah, another adventurer looking for a fortune.",
      "Eh? What do you want?",
      "I hear that South Tyris is a violent and uninhabitable land.  Who knows what sort of horrors lurk there."
   },

   ally_default = {
      function(npc, player, params)
         return ("(%s fixedly looks at you.)")
            :format(npc.name)
      end,
      "...?",
      "Did you need something?",
      "What do you want?",
      "What's up?",
      "Is something wrong?",
      "What is it?"
   },

   prostitute = {
      "Hey sexy, wanna relax for a while?"
   },

   bored = {
      function(npc, player, params)
         return ("(%s is bored. )")
            :format(npc.name)
      end,
      function(npc, player, params)
         return ("(%s glances at you and steps back.)")
            :format(npc.name)
      end
   },

   fortune_cookie = {
      blessed = {
         "You can dry out fresh meat at a ranch to make jerky for rations.",
         "If you worship Kumiromi, you might find seeds in rotten meat.",
         "A ranch near Derphy can be highly profitable. ",
         "Do not ever waste material kits on normal items!",
         "Herbs are real value if you feed them to your pet.",
         "Better tools give you better results for your skills. Better beds give you better dreams if you sleep in them.",
         "Tax will be lowered if your karma is high.",
         "Shopkeepers will pay more for monster's shit that weights more.",
         "A blessed potion of descent will raise your level.",
         "Drinking cursed healing potions sometimes makes you sick.",
         "If you want a new skill, read a blessed scroll of gain attribute.",
         "You will get more chances of critical hits against dimmed opponents.",
         "While poisoned, bleeding, or paralyzed, your opponent won't regenerate. ",
         "The cubes will not split when they have bad conditions.",
         "You can use a scroll of superior material to an artifact to re-create the artifact.",
         "You can prevent getting dimmed by increaseing your resistance to sound.",
         "You can prevent getting insane by increaseing your resistance to mind.",
         "Blessing a rod is a good idea. But the effects of blessed rods are less dramatic than blessed potions or scrolls.",
         "When you are wet, fire damages won't be a problem but electric damages will be a serious threat.",
         "If you vomit too much in a short period, you will suffer anorexia. When you get anoerxia, don't eat. Just drink potions and water.",
         "A blessed potion of restore body or restore spirit will enchance your body or spirit.",
         "Throw cursed potions of restore body or restore spirit at powerful opponents.",
         "You *should* bless the hermes blood before drinking it!",
         "It would be really bad if something wrong happenes when you cast the return spell."
      },
      normal = {
         "A Nymph will be very pleased if you call her by her real name:  Lorelei.",
         "A ring of extra ring finger is useless if not enchanted.",
         "A staff may recharge if you drop it for awhile.",
         "Not sure what you should wish for? Try secret artifact of milas.",
         "Gems can be traded for platinum coins.",
         "Always bless the treasure maps before reading.",
         "Meo....eow.....",
         "If you have the swimming skill, you can swim across to another continent.",
         "What do you wish for?",
         "If you shout 'Guards!' in the chat window, they may quickly come to help you.",
         "There's a way to make God your pet.",
         "Player killers await you when you enter moongates.",
         "Oh, what a pity. Hate to say but those who read this fortune *will* be cursed.",
         "Watch your back! Careful! T-There, your younger sister! Run!",
         "Nyo BUMP-BUMP for you!",
         "The game could not choose valid fortunes as your saved game is corrupted.",
         "It is rumored that killing cats make you unlucky.",
         "Reading a blessed scroll of oracle before opening a chest is believed to bring you equipment with good enchantments. ",
         "Guards will be pleased if you bash them naked.",
         "It is rumored that there's an ultimate artifact exclusive to your younger sisters.",
         "You can only learn swimming skill by wishing."
      }
   },

   christmas_festival = {
      "Welcome to the Holy Night Festival! Enjoy yourself!",
      "The Holy Night Festival is also known as the Festival of St.Jure. This is a feast to honor the Goddess of Healing and to celebrate the end of the year.",
      "I heard Moyer is preparing some showpiece for the festival.",
      "You, have you seen the great celestial statue of Jure yet? Oh, what a beautiful woman she is!",
      "I will meet my lover tonight!",
      "Many tourists visit this town just to see the festival at this time of year.",
      "The Holy Night Festival is an old and historical event. It is said that even the royal family of Palmia used to visit this little town to offer their prayers to St.Jure.",
      "A legend says Jure's tear can cure any diseases. In fact, there have been many witnesses of her miracles in the past events. Such as an old blind woman recovering sight, can you believe it?"
   },

   maid = {
      function(npc, player, ref)
         return ("Welcome home, %s. You have %s waiting for you. Do you want to meet a guest now?")
            :format(basename(player), ref)
      end
   },

   moyer = {
      "Hear hear! This monster before you is the notorious fire giant who ruled Verron of Nefia for a century. You're lucky, quite lucky to have him chained before you today! Indeed, this monster could burn the whole village if it weren't for the magical chains that bind him. Buy some goods at my shop, and I will even let you touch this fearsome giant!",
      "Don't worry. He can't move a muscle while he is shackled."
   },

   personality = {
      ["0"] = {
         "King Xabi is a man of his word.  You can trust him with anything.",
         "I want to drink crim ale to death!",
         "What's an another name for a hare's tail?",
         "King Xabi is a wise man.  At least, that's what I've heard.",
         "Sometimes I drink crim ale until I pass out.",
         "Cats... why are they so cute?",
         "Yerles is a new kingdom that has recently risen to prominence.",
         "Eulderna was the first country to explore and research the ruins of Nefia.",
         "I wonder if the shopkeepers really are invincible...",
         "Apparently, there is a way to learn the location of artifacts after all.",
         "Hungry sea lions love to eat fish.",
         "Sleep and rest well when you are sick! My grandma told me the blessed healing potion also works."
      },
      ["1"] = {
         "Money makes the world go round.  I wonder where I can get some more money.",
         "Money and currency are critical to our society. ",
         "Do you have any good ideas for investments?",
         "I'm very much into economics. ",
         "Platinum coins are a lot rarer than gold.  Spend them wisely. ",
         "Eulderna always suffers from huge deficits, but it never really seems to slow them down.  They can't just invent money like that forever.",
         "Zanan's postwar system is a monarchy, but internally the country still operates on the outdated systems used during Eyth Terre."
      },
      ["2"] = {
         "Sierre Terre is the 11th era on Irva.",
         "Are you on drugs? Irva is our world, of course.",
         "The land of North Tyris has countless ruins and dungeons on it.  They are part of a long lost civilization called Nefia.",
         "Science in the eighth era of Eyth Terre was far more advanced than ours.",
         "In Eyth Terre, magic and science were thought to be opposites.",
         "I like talking about science. ",
         "Vernis is the biggest coal-mining town in North Tyris.",
         "Lumiest is the famous city of art. "
      },
      ["3"] = {
         "You should never leave home without an ample supply of food.  Starving to death would be a pretty abysmal fate.",
         "Eternal League...? I've never heard of that. ",
         "Sierre Terre is the 11th era.",
         "I like travelling.  I've been to so many places.",
         "If you find adventuring too difficult by yourself, go to Derphy and buy a few slaves to watch your back.",
         "Don't drop items in your shop that you want to keep. They will probably be sold!",
         "You can safely store items in buildings that you own.",
         "If you drop items in a town, the janitors will probably dump them.",
         "Guards will attack you if your karma drops too low.  At least *try* to keep a low profile.",
         "If your pets and allies fall in combat, bartenders in town can bring them back.",
         "Be sure to give good equipment to your allies and pets, since it will make them more effective in battle.",
         "Potions that reverse the effects of the etherwind exist, but they are rare and quite valuable.",
         "If you're planning to buy a building, start with a museum. The maintenance cost is cheap and they start making a profit quickly.",
         "One of your best sources of income and fame is the arena.",
         "If you are having hard time traveling, maybe you should purposely lower your fame.",
         "Gamble chests are good for practicing lock picking."
      }
   },

   rumor = {
      loot = {
         "Rabbit's tails are said to bring good luck to those who eat them.",
         "It's rumored that some beggars carry a magical pendant which purifies their stomach.",
         "Zombies sometimes drop a strange potion.",
         "Once I met this extraordinary bard who played a truly exquisite stringed instrument. He was so good that I even threw my expensive shoes at him!",
         "I've heard mummies carry a book that has power to resurrect the dead.",
         "I swear I saw it. The executioner came back to life after he got his head lopped off!",
         "Those who gaze into deformed eyes mutate. But they say that sometimes the eyes carry a potion that makes creatures evolve.",
         "Fairies hide a secret experience!",
         "Don't underestimate the rock thrower.  His rock can be very deadly.",
         "Those silver-eyed witches are deadly. You won't stand a chance against their huge swords.  I've heard they're not completely human and supposedly one of them carries even deadlier weapon.",
         "I saw a cupid carrying very heavy... thing.",
         "I met my god in a dream!",
         "If you ever encounter a four-armed monster wearing a yellow necklace, you'd better run like hell.",
         "Rogue assassins sometimes carry a magical necklace that gives you an extra attack.",
         "Some nobles collect strange things.",
         "Watch out for drunkards at parties! They sometimes throw crazy things at you.",
         "I saw a robot wearing a red plate girdle.",
         "A magical scroll imps carry can change the name of an artifact.",
         "The innocent girl in Yowyn has a secret treasure.",
         "Some time ago, I saw a hermit crab carrying a beautiful shell I've never seen before.",
         "Those robbing bastards, I hear they are addicted to some drugs."
      }
   },

   shopkeeper = {
      "Welcome to my shop!",
      "We have the best selection of goods!",
      "I hate thieves.  No, not you, right?",
      "It's difficult to maintain a shop.",
      "I can handle bandits myself. We have to be tough.",
      "Running a store is hard work! ",
      "Come in.  Take a closer look at my wares. ",
      "I have confidence in my assortment of goods. ",
      "Look at our fine selection.",
      "I feel the world is growing more and more dangerous.",
      "I can't give you a fair price if your weapons and armors aren't fully identified."
   },

   slavekeeper = {
      "He he he.  I think I have just what you need.",
      "Don't look at me like that.",
      "What's your problem?"
   },

   area = area,

   params = {
      maid = function(_1)
         return ("%s guest%s")
            :format(_1, plural(_1))
      end
   },
}

return {
   talk = {
      random = random
   }
}
