"Akkoteaque" by Anthony Casteel

Release along with cover art, an interpreter, and the introductory booklet.

include Player Experience Upgrade by Aaron Reed.
include Epistemology by Eric Eve.
include Conversation Package by Eric Eve.
include Locksmith by Emily Short.
include Plurality by Emily Short.
include Basic Screen Effects by Emily Short.
include Glulx Text Effects by Emily Short.
include Punctuation Removal by Emily Short.
include Case Management by Emily Short.
include Complex Listing by Emily Short.
include Modified Far Away by Anthony Casteel.
include Far Away by Jon Ingold.
include Hidden Items by Krister Fundin.
include Intelligent Hinting by Anthony Casteel.
include Intelligent Hinting by Aaron Reed. [Commented out]

Use DICT_WORD_SIZE of 15.
Use MAX_STATIC_DATA of 360000.
Use MAX_PROP_TABLE_SIZE of 400000.
Use single room approaches. [Configures 'Player Experience Upgrade' to disallow the 'go to' command.]
[Use traditional can't see any such thing. ][Stops the 'you don't have to use 'foo' in that way' message. Avoids leaking information about unseen objects, too.]
Use empty Smarter Parser rulebook. [Smarter parser is too damn slow]

Report requesting the story file version:
   say "This game uses code based on Exit Lister by Gavin Lambert.";
   
Section - Remembering room locations

First for saying the location name of a room (this is the new Remembering saying room name rule): say "[the printed name of the item described]".  
	
Section - Fixing disambiguation weirdness

Include (-

[ Descriptors  o x flag cto type n hold signal;
   hold = 0;
   signal = 0;
   ResetDescriptors();
   if (wn > num_words) return 0;

   for (flag=true : flag :) {
      o = NextWordStopped(); flag = false;

      for (x=1 : x<=LanguageDescriptors-->0 : x=x+4)
         if (o == LanguageDescriptors-->x) {
            flag = true;
            type = LanguageDescriptors-->(x+2);
            if (type ~= DEFART_PK) indef_mode = true;
            indef_possambig = true;
            indef_cases = indef_cases & (LanguageDescriptors-->(x+1));

            if (type == POSSESS_PK) {
               cto = LanguageDescriptors-->(x+3);
               switch (cto) {
                 0: indef_type = indef_type | MY_BIT;
                 1: indef_type = indef_type | THAT_BIT;
                 default:
                  indef_owner = PronounValue(cto);
                  if (indef_owner == NULL) indef_owner = InformParser;
               }
            }

            if (type == light)  indef_type = indef_type | LIT_BIT;
            if (type == -light) indef_type = indef_type | UNLIT_BIT;
         }

      if (o == OTHER1__WD or OTHER2__WD or OTHER3__WD) {
         indef_mode = 1; flag = 1;
         indef_type = indef_type | OTHER_BIT;
         signal = 1;
      }
      if (o == ALL1__WD or ALL2__WD or ALL3__WD or ALL4__WD or ALL5__WD) {
         indef_mode = 1; flag = 1; indef_wanted = INDEF_ALL_WANTED;
         if (take_all_rule == 1) take_all_rule = 2;
         indef_type = indef_type | PLURAL_BIT;
         signal = 1;
      }
      if (allow_plurals) {
         if (NextWordStopped() ~= -1) { wn--; n = TryNumber(wn-1); } else { n=0; wn--; }
         if (n == 1) { indef_mode = 1; flag = 1; }
         if (n > 1) {
            indef_guess_p = 1;
            indef_mode = 1; flag = 1; indef_wanted = n;
            indef_nspec_at = wn-1;
            indef_type = indef_type | PLURAL_BIT;
         }
      }
      if (flag == 1 && NextWordStopped() ~= OF1__WD or OF2__WD or OF3__WD or OF4__WD) {
         hold=1;
         wn--;  ! Skip 'of' after these
      }
   }
   wn--;
   if (hold == 1) {
      hold=0;
      if (signal == 0) {
         wn--;
      }
      else {
         signal = 0;
      }
   }
   return 0;
];

[ SafeSkipDescriptors;
   @push indef_mode; @push indef_type; @push indef_wanted;
   @push indef_guess_p; @push indef_possambig; @push indef_owner;
   @push indef_cases; @push indef_nspec_at;
   
   Descriptors();
   
   @pull indef_nspec_at; @pull indef_cases;
   @pull indef_owner; @pull indef_possambig; @pull indef_guess_p;
   @pull indef_wanted; @pull indef_type; @pull indef_mode;
];

-) instead of "Parsing Descriptors" in "Parser.i6t".

Section - Beta command logging

[This lets players log things into their play log without invoking the parser.]
	
After reading a command (this is the ignore beta-comments rule): 
	if the player's command matches the regular expression "^\p": 
		say "(Noted.)"; 
		reject the player's command. 
		
Section - Credits

Listing the credits is an action out of world applying to nothing.
Understand "credits" as Listing the credits.
Report listing the credits:
	Say "Special thanks to my testers - [line break]  Andrew Schultz[line break]  Olly from ifmud[line break]  Antiquarian[line break]  climbingstars";
	

Chapter - VERB command

Include Repeat Through Actions by Ron Newcomb;

Listing every verb is an action out of world applying to nothing.
Understand "verbs" as listing every verb.

Carry out listing every verb:
	Repeat with A running through every action:
		Say "[A][if A is out of world] (out of world)[end if][line break]".

Chapter - Stripping The from input

First after reading a command (this is the strip the from input rule): 
	Now the reborn command is the player's command;
	if stripping "the" is fruitful:
		change the text of the player's command to "[reborn command]".
		
Chapter - Hyperlink Interface

Section - Initiation

Include Inline Hyperlinks by Erik Temple.

Hyperlink-mode is a number that varies. Hyperlink-mode is 1.

Mode switching is an action out of world applying to one topic. Understand "mode [text]" as mode switching.
Implicit mode is an action out of world applying to nothing. Understand "mode" as implicit mode.

After reading a command:
	if the player's command includes "mode" or the player's command includes "hyperlinks":
		If the player's command includes "none" or the player's command includes "off":
			Now hyperlink-mode is 0;
			Now the command prompt is ">";
		Otherwise if the player's command includes "hilite":
			Now hyperlink-mode is 1;
			Now the command prompt is ">";
		Otherwise if the player's command includes "link" or the player's command includes "on" or the player's command includes "links":
			Now hyperlink-mode is 2;
			Now the command prompt is "[link]look[end link] - [link]commands[end link]>";
		Otherwise if the player's command includes "blind" or the player's command includes "accessible" or the player's command includes "impaired":
			Now hyperlink-mode is 3;
			Now the command prompt is ">";
		Otherwise:
			Say "(Use the mode command to switch between different modes of presenting this story. The available modes are[line break]none - There will be no hiliting and no text[line break]hilite - Keywords, object names, and other important text is hilited[line break]links - Keywords, object names, and important text becomes links that enter commands[line break]accessible - Like hilite, except hiliting is done *like this* rather than using text color[line break]Type 'mode mode-of-choice' to change the mode.)";
		If hyperlink-mode is 0:
			Say "(All hiliting and linking is disabled. You can re-enable it with the 'mode' command. Try 'mode help' for a description of available modes.)";
		If hyperlink-mode is 1:
			Say "(Normal hiliting is enabled. You can change the mode with the 'mode' command. Try 'mode help' for a description of available modes.)";
		if hyperlink-mode is 2:
			Say "(Linking and hiliting is enabled. You can disable it with the 'mode' command. Try 'mode help' for a description of available modes. Every action necessary to complete the game is possible in this mode, but some fun but unecessary actions are not accessible.)";
		if hyperlink-mode is 3:
			Say "(Accessible mode enabled. You can change the mode with the 'mode' command. Try 'mode help' for a description of available modes.)".

To decide whether hyperlinks are currently enabled:
	if hyperlink-mode is 2, decide yes;
	decide no.
	
To decide whether hyperlinks are currently disabled:
	If hyperlink-mode is 2, decide no;
	decide yes.

To say end link: [These links only appear hilited in mode 2.]
	let hyperlink index be a number;
	stop capturing text;
	if the hyperlinked text is "":
		now the hyperlinked text is "[captured text]";
	now the hyperlinked command is "[captured text]";
	If hyperlink-mode is 0:
		Say "[hyperlinked text]";
	If hyperlink-mode is 1:
		Say "[hyperlinked text]";
	If hyperlink-mode is 2:
		if the hyperlinked command is listed in the hyperlink list:
			repeat with count running from 1 to the number of entries in the hyperlink list:
				if entry (count) of the hyperlink list is hyperlinked command:
					let hyperlink index be count;
		otherwise unless the hyperlinked command is "":
			add hyperlinked command to hyperlink list;
			let hyperlink index be the number of entries of hyperlink list;
		say "[set link (hyperlink index)][hyperlinked text][terminate link]";
	If hyperlink-mode is 3:
		Say "[hyperlinked text]".
		
To say end link hilite: [Links ended this way will hilite in modes 1 and 3.]
	let hyperlink index be a number;
	stop capturing text;
	if the hyperlinked text is "":
		now the hyperlinked text is "[captured text]";
	now the hyperlinked command is "[captured text]";
	If hyperlink-mode is 0:
		Say "[hyperlinked text]";
	If hyperlink-mode is 1:
		Say "[interest][hyperlinked text][normal]";
	If hyperlink-mode is 2:
		if the hyperlinked command is listed in the hyperlink list:
			repeat with count running from 1 to the number of entries in the hyperlink list:
				if entry (count) of the hyperlink list is hyperlinked command:
					let hyperlink index be count;
		otherwise unless the hyperlinked command is "":
			add hyperlinked command to hyperlink list;
			let hyperlink index be the number of entries of hyperlink list;
		say "[set link (hyperlink index)][hyperlinked text][terminate link]";
	If hyperlink-mode is 3:
		Say "*[hyperlinked text]*".
		
When play begins:
	Say "[bracket]Akkoteaque can be played in several different modes. Currently, it is in hilite mode. Hiliting can be turned off. Akkoteaque can also be played in hyperlink mode, where most actions are available from hyperlinks, and accessible mode, which uses a form of hiliting friendly to the visually impaired. Use the 'mode' command to change the mode. Try 'mode help' to get a description of available modes.[close bracket]".
	

Section - Glulx colors for use when hyperlinks are disabled

Table of User Styles (continued) 
style name	boldness	glulx color
special-style-1	bold-weight	g-faded-blue
special-style-2	bold-weight	g-faded-red

Table of Common Color Values (continued)
glulx color value	assigned number
g-faded-blue	2846917
g-faded-red	9257538

To say interest:
	say first custom style.
To say command:
	say second custom style.
To say normal:
	say roman type.
To say italic:
	say italic type.
	
Section - Printing names of things (Links and Holy)
	
To say x (bob - a thing):
	Say "[link][if bob is holy]holy [end if][the printed name of bob][as]x [the printed name of bob][end link]".
		
Rule for printing the name of a thing (called Bob):
	Say "[link][if bob is holy]holy [end if][the printed name of Bob][as]x [the printed name of Bob][end link]".
	
[Rule for printing the name of a person (called Bob):
	Say "(NAME PERSON PRINTING: [indefinite article of Bob] [the printed name of Bob] [if Bob is proper-named]PROPER[end if])";
	If Bob is not proper-named:
		Say "[the indefinite article of Bob] [link][the printed name of Bob][as]x [the printed name of Bob][end link]";
	Otherwise:
		Say "[link][the printed name of Bob][as]x [the printed name of Bob][end link]";]
	
Rule for printing the name of a thing (called Bob) when printing suggestion is true:
	Say "[the printed name of Bob]".
	
To say the (person - a person):
	If person is introduced:
		say "[person]";
	Otherwise:
		say "the [person]".
		
To say The (person - a person):
	If person is introduced: [Duplicate the printing the name of rule just so we can capitalize Holy]
		say "[link][if person is holy]Holy [end if][the printed name of person][as]x [the printed name of person][end link]";
	Otherwise:
		say "The [person]".
		
Rule for printing the name of a thing (called the current topic) while listing suggested topics (this is the print ask link rule):
	If the current topic is the current interlocutor:
		If the current interlocutor is not proper-named:
			Say "the "; [Hack because the interlocutor appears before the list]
	Say "[link][the printed name of the current topic][as]ask [the printed name of the current interlocutor] about [the printed name of the current topic][end link]".


Section - Hyperlink Actions

A hyperlink action is a kind of thing.
A hyperlink action has some text called the command text.

[Projected hyperlink actions appear in the 'global' command list as well as the object list.]
A hyperlink action can be projected. A hyperlink action is usually not projected.
An object has a list of hyperlink actions called the special actions.
A standard hyperlink action is a kind of hyperlink action.
A global hyperlink action is a kind of hyperlink action.

The active item is an object that varies.

The action fruitful rules is an object-based rulebook with default success.

Action fruitful rule for something:
	Rule succeeds.

Section - Standard actions involving objects

The take action is a standard hyperlink action with printed name "take [if the active item is not proper-named]the [end if][printed name of the active item]" and command text "get [printed name of the active item]".
Action fruitful rule for the take action:
	If the active item is fixed in place:
		Rule fails;
	If the player encloses the active item:
		Rule fails;
	If the active item is a person:
		Rule fails.
		
The drop action is a standard hyperlink action with printed name "drop [if the active item is not proper-named]the [end if][printed name of the active item]" and command text "drop [printed name of the active item]".
Action fruitful rule for the drop action:
	If the player does not enclose the active item:
		Rule fails.
		
The greet action is a standard hyperlink action with printed name "say hello" and command text "talk to [printed name of the active item]".
Action fruitful rule for the greet action:
	If the active item is not a person:
		Rule fails;
	If the active item is the current interlocutor:
		Rule fails.
		
The suggest topics action is a standard hyperlink action with printed name "suggest conversation topics" and command text "topics".
Action fruitful rule for the suggest topics action:
	If the active item is not a person:
		Rule fails;
	If the active item is not the current interlocutor:
		Rule fails.
		
The enter-enterable-container-action is a projected standard hyperlink action with printed name "enter the [printed name of the active container of enter-enterable-container-action]" and command text "enter [printed name of the active container of enter-enterable-container-action]".
The enter-enterable-container-action has an object called the active container.
Action fruitful rule for enter-enterable-container-action:
	Now the active container of enter-enterable-container-action is the active item;
	If the active item is not enterable:
		Rule fails;
	If the active item encloses the player:
		Rule fails.
		
The exit-container-action is a standard hyperlink action with printed name "exit" and command text "exit".
Action fruitful rule for exit-container-action:
	If the active item does not enclose the player:
		Rule fails.

The open-openable-thing-action is a standard hyperlink action with printed name "open it" and command text "open [printed name of the active item]".
Action fruitful rule for open-openable-thing-action:
	If the active item is not openable:
		Rule fails;
	If the active item is open:
		Rule fails.
		
The close-openable-thing-action is a standard hyperlink action with printed name "close it" and command text "close [printed name of the active item]".
Action fruitful rule for close-openable-thing-action:
	If the active item is not openable or the active item is closed:
		Rule fails.
		
The put-charm-on-bracelet-action is a standard hyperlink action with printed name "put it on the bracelet" and command text "put [printed name of the active item] on bracelet".
Action fruitful rule for put-charm-on-bracelet-action:
	If the active item is not a charm, rule fails;
	If the player encloses the bracelet, rule succeeds;
	Rule fails.
	
Section - Building a list of object actions
		
A thing can be action-list-suppressed. A thing is usually not action-list-suppressed.
		
After examining something (called the item) when hyperlinks are currently enabled:
	If the item is action-list-suppressed:
		Continue the action;
	Now the active item is the item;
	Let L be a list of hyperlink actions;
	Repeat with B running through every standard hyperlink action:
		Consider the action fruitful rules for B;
		If the rule succeeded:
			Add B to L, if absent;
	Repeat with B running through the special actions of the item:
		Consider the action fruitful rules for B;
		If the rule succeeded:
			Add B to L, if absent;
	If the number of entries in L is not 0:
		If the number of entries in L is 1:
			Say "You could [link][printed name of entry 1 in L][as][command text of entry 1 in L][end link].";
		Otherwise:
			Say "You could..";
			Repeat with A running through L:
				Say "  [link][printed name of A][as][command text of A][end link].";
	Continue the action.
	
				
Section - Global hyperlink actions

The look action is a global hyperlink action with printed name "look around" and command text "look".

The wait action is a global hyperlink action with printed name "do nothing at all" and command text "wait".
	
The list inventory action is a global hyperlink action with printed name "see what you are carrying" and command text "inventory".

Section - Listing basic commands

Listing basic commands is an action out of world applying to nothing.
Understand "commands" as listing basic commands.

Carry out listing basic commands:
	Let L be a list of hyperlink actions;
	Now the active item is nothing;
	Repeat with B running through every global hyperlink action:
		Consider the action fruitful rules for B;
		If the rule succeeded:
			Add B to L, if absent;
	Repeat with B running through the special actions of the location of the player:
		Consider the action fruitful rules for B;
		If the rule succeeded:
			Add B to L, if absent;
	If something encloses the player:
		Let X be a random thing that encloses the player;
		Now the active item is X;
		Repeat with C running through the special actions of X:
			Consider the action fruitful rules for C;
			If the rule succeeded:
				Add C to L, if absent;
	Repeat with item running through every visible thing:
		Now the active item is item;
		Repeat with C running through the special actions of item:
			If C is projected:
				Consider the action fruitful rules for C;
				If the rule succeeded:
					Add C to L, if absent;
	If the number of entries in L is not 0:
		If the number of entries in L is 1:
			Say "You could [link][printed name of entry 1 in L][as][command text of entry 1 in L][end link].";
		Otherwise:
			Say "You could..";
			Repeat with A running through L:
				Say "  [link][printed name of A][as][command text of A][end link].".
	
Section - Listing Exits

A room can be exits-visible or exits-invisible. A room is usually exits-visible.
A room has a text called list-name. List-name of a room is usually "[printed name]".

To say closed door: say "(closed)".

To say no obvious exits: say "You can see no obvious exits."

A door has a text called passing text. Passing text of a door is usually "through".
A door has a text called closed text.  Closed text of a door is usually "[closed door]".
A door can be obvious.  Doors are usually obvious.

The exit obviousness rules are an object-based rulebook.  The door obviousness rules are an object-based rulebook.

Last door obviousness rule for a door (called gateway) (this is the check obvious doors rule):
	if gateway is not obvious, rule fails.

An exit obviousness rule for a room (called place) (this is the darkness hides exits rule):
	if not in darkness, make no decision;
	if place is not visited, rule fails.

To decide if (way - a direction) is a listable exit:
	let place be the room way from the location;
	if place is not a room then decide no;
	consider the exit obviousness rules for place;
	if the rule failed, decide no;
	let gateway be the room-or-door way from the location;
	if gateway is a door
	begin;
		consider the door obviousness rules for gateway;
		if the rule failed, decide no;
	end if;
	decide yes.

Definition: A direction is exit-listable if it is a listable exit.

Listing exits is an activity.

The last for listing exits rule (this is the standard exit listing rule):
	let exits be the number of exit-listable directions;
	if exits is 0:
		[say "[no obvious exits]";]
		Stop the action;
	Let L be the list of exit-listable directions;
	If exits is 1:
		Let E be entry 1 of L;
		Say "You can only go [link][E][as][printed name of E][end link]";
		Let place be the room E from the location;
		Let gateway be the room-or-door E from location;
		If gateway is a door:
			Say " ([passing text of gateway] [link][the printed name of the gateway][as]x [the printed name of the gateway][end link]";
			If gateway is closed:
				Say " [closed text of gateway]";
			Say ")";
		If place is visited:
			Say " (to [the list-name of the place])";
		Say " from here.";
	Otherwise:
		Say "You can go[line break]";
		Repeat with E running through L:
			Say "  [link][E][as][printed name of E][end link]";
			Let place be the room E from the location;
			Let gateway be the room-or-door E from location;
			If gateway is a door:
				Say " ([passing text of gateway] [link][the printed name of the gateway][as]x [the printed name of the gateway][end link]";
				If gateway is closed:
					Say " [closed text of gateway]";
				Say ")";
			If place is visited:
				Say " (to [the list-name of the place])";
			Say "[line break]".

This is the exits rule: if the location of the player is exits-visible, carry out the listing exits activity.
The exits rule is listed last in the carry out looking rules.

Listing exits is an action applying to nothing.
Understand the command "exits" as something new.
Understand "exits" as listing exits.
Carry out listing exits: carry out the listing exits activity.

[Keep doors from appearing in the room contents since they now appear in the exits list]
Before listing nondescript items of a room (called the room):
	repeat with door running through every door in the room:
		now the door is not marked for listing.



Chapter - Scoring

Rule for printing the name of something (called the item) when requesting the score:
	Say "[the printed name of the item]".
	
The announce the score rule is not listed in the carry out requesting the score rulebook.

The scored item list is a list of indexed texts that varies.

To award (num - a number) point/points with message (text - some indexed text):
	Increase the score by num;
	Add text to the scored item list.
	
First carry out requesting the score (this is the itemized score rule):
	If the number of entries in scored item list is 0:
		Say "You have scored no points ";
	Otherwise:
		If the number of entries in scored item list is 1:
			Say "You have scored [entry 1 of scored item list] ";
		Otherwise:
			Say "You have scored[line break]";
			Repeat with T running through scored item list:
				Say "  [T];[line break]";
	Say "out of a possible [maximum score] points.[line break]";
	Continue the action.
	
Section - Fixing the Score (in place of Section - Fixing the Score in Player Experience Upgrade by Aaron Reed)

[Just excise the score bit.]


Chapter - World Model

Door obviousness of a hidden door:
	Rule fails.
	
Section - Helpful synonyms
	
Understand "off" as exiting.
Understand "board" as entering.

Instead of searching something:
	Try examining the noun.
	
Section - Revealing and hiding by saying

To say reveal (item - a thing):
	Reveal item.
	
To say hide (item - a thing):
	Hide item.

Section - Characters and conversation


[A person always starts off anonymous. The player shouldn't see their name printed until they are introduced.]

Understand "ask about/-- [text]" or "a about/-- [text]" as implicit-asking.
Understand "t about/-- [text]" as implicit-telling.
Understand "ask about/-- [any known thing]" or "a about/-- [any known thing]" as implicit-quizzing.
Understand "t about/-- [any known thing]" or "talk about/-- [any known thing]" as implicit-informing.

A person can be introduced or anonymous. A person is usually anonymous.
A person has some text called the real name. The real name is usually "[the printed name]".
The indefinite article of a person is usually "a".
A person is usually not proper-named.
A person has an object called the associated subject. The associated subject of a person is usually nothing.
Yourself is introduced.

To introduce (bob - a person):
	[Say "(Introducing [bob])";]
	Now bob is proper-named;
	Now the printed name of bob is the real name of bob;
	Now bob is introduced;
	If the associated subject of bob is not nothing:
		Repeat with P running through every person:
			If (associated subject of bob) is listed in (ask-suggestions of P):
				Remove (associated subject of bob) from (ask-suggestions of P);
				Add bob to (ask-suggestions of P), if absent;
			If (associated subject of bob) is listed in (previous-topics of P):
				Remove (associated subject of bob) from (previous-topics of P);
				Add bob to (previous-topics of P), if absent;
		Now the associated subject of bob is unfamiliar;
		
Before quizzing a person (called the interlocutor) about the player:
	If the interlocutor is the player:
		Say "Talking to yourself just makes you look crazy.";
		Stop the action;
	If the player's command includes "self":
		Say "([it-them of the interlocutor][if the interlocutor acts plural]selves[otherwise]self[end if])";
		Try quizzing the interlocutor about the interlocutor instead.

A person can be audible-at-a-distance. A person is usually not audible-at-a-distance.

Definition: a person is audible at a distance if it is not far-off or it is audible-at-a-distance.

[Customize Eric Eve's Conversation Package.]

[The final default response provided by Conversation Responses is 'X does not respond'. Replace it with a message that lets the player know that the character will respond to certain things, and list known topics.]
	
The unresponsive rule is not listed in any rulebook.

Check saying hello to someone (called the person) (this is the can't greet distant people rule):
	If the person is far-off and the person is not audible at a distance:
		Say "[The person] is too far away to hear you.";
		Stop the action.
		
Check saying hello to the player (this is the can't talk to self rule):
	Say "Talking to yourself just makes you look crazy.";
	Stop the action.
		
Before conversing when the current interlocutor is far-off and the current interlocutor is not audible at a distance:
	Say "[The current interlocutor] is too far away to hear you.";
	Stop the action.
	
The last default response rule (this is the new unresponsive rule):  [Only considered when the player asks about nonsense.]
	Say "[as the parser]Characters will only respond if asked about things or people you encounter in the world.[normal]";
	[Try the player listing suggested topics.]
	
[A default response for characters asked about actual things (The new unresponsive rule catches nonsense)]
Last response of someone (called the actor) when asked about something (called the item):
	Say "[The actor] doesn't have anything specific to say about [the second noun].";
	[Try the player listing suggested topics.]
	
Last response of someone when told about something (This is the default tell to ask rule):
	Try the player quizzing the noun about the second noun instead.
	
Last response of someone when shown something (This is the default show to ask rule):
	Try the player quizzing the second noun about the noun instead.
	
Last response of someone when given something (This is the default give to ask rule):
	Try the player quizzing the second noun about the noun instead.
	
Understand the command "feed" as something new.
Understand the command "feed" as "give".

A person has a list of objects called previous-topics.
A convnode has a list of objects called previous-topics.

[Remove things asked about from the suggestion list.]
After quizzing someone (called the actor) about something (called the item) (this is the remove asked about suggestions rule):
	Let the actual topic be the item;
	If the item is the actor:
		Now the actual topic is the self-suggestion;
		Remove the actor from the ask-suggestions of the appropriate-suggestion-database, if present;
	If the actual topic is listed in the ask-suggestions of the appropriate-suggestion-database:
		Add the actual topic to the previous-topics of the appropriate-suggestion-database, if absent;
	Remove the actual topic from the ask-suggestions of the appropriate-suggestion-database, if present;
	The topic list displays in 0 turns from now;
	Continue the action.
	
[Replace nothing specific so it does not leak the name of unintroduced characters]
To say nothing specific:
   say "You have nothing specific in mind to discuss with [current interlocutor] right now.";
   
To start a conversation with (the new speaker - a person):
	Now the current interlocutor is the new speaker;
	Try the player listing suggested topics.

Check listing suggested topics (this is the don't list topics if the interlocutor is gone rule):
	If the listing protocol is suppressed:
		Now the listing protocol is allowed;
		Stop the action;
	If the current interlocutor is not nothing:
		If the location of the current interlocutor is not the location of the player:
			[Say "[The current interlocutor] doesn't seem to be here.";]
			Stop the action.
			
Every turn when the listing protocol is suppressed:
	Now the listing protocol is allowed.
	
Every turn when the location of the current interlocutor is not the location of the player:
	Now the current interlocutor is nothing.
			
A suppressor protocol is a kind of value. The suppressor protocols are suppressed and allowed.
The listing protocol is a suppressor protocol that varies. The listing protocol is allowed.

To suppress listing topics:
	Now the listing protocol is suppressed.

Section - Carry out listing (in place of Section 1 - Carry Out Listing in Conversation Suggestions by Eric Eve)

Carry out listing suggested topics:
	consider the suggestion list construction rules;
	let ask-suggs be the number of entries in sugg-list-ask;
	let tell-suggs be the number of entries in sugg-list-tell;
	let other-suggs be the number of entries in sugg-list-other;
	if ask-suggs + tell-suggs + other-suggs is 0:
		say "[nothing specific]";
	Otherwise:
		say "[if topic-request is implicit]([end if]You could ";
		if other-suggs > 0 then
			say "[sugg-list-other in topic format][if tell-suggs + ask-suggs > 0]; or [end if]";
		if ask-suggs > 0 then
			say "ask [current interlocutor] about [sugg-list-ask in topic format][if tell-suggs > 0]; or [end if]";
		if tell-suggs > 0 then
			say "tell [current interlocutor] about [sugg-list-tell in topic format]";
		say "[if topic-request is implicit].)[paragraph break][otherwise].[end if]";
	If topic-request is explicit or ask-suggs + tell-suggs + other-suggs is 0:
		let sugg-list-prev be the previous-topics of the appropriate-suggestion-database;
		let previous-suggs be the number of entries in sugg-list-prev;
		if previous-suggs > 0 then
			Say "[If topic-request is implicit]([end if]You've previously asked [current interlocutor] about [sugg-list-prev in previous format][if topic-request is implicit].)[paragraph break][otherwise].[end if]".
		
To say (l - a list of objects) in previous format:
	set up l for topic printing;
	say "[the prepared list delimited in sequential style]";
 
 
		
Section - Automatically examine objects the first time they are picked up

To decide whether the action is singular:
	let L be the multiple object list;
	if the number of entries in L is less than 2:
		yes;
	no.

A thing can be examined or unexamined. A thing is usually unexamined.

To say (item - a thing) description:
	say "[description of the item]";
	now the item is examined.

Carry out examining something:
	now the noun is examined.

Report taking something (this is the examine things on taking rule):
	Say "Taken.";
	If the action is singular:
		If the noun is unexamined:
			Say "[line break][noun description][line break]";
			Now the noun is examined;
	Stop the action.
	



	

Section - Stair cases and porch doors
		
A staircase is a kind of door. A staircase is usually open. A staircase is seldom openable. Passing text of a staircase is "climbing". The specification is "A door that is always open and supports the verb 'climb' as an alias for enter.".

Instead of climbing a staircase:
	try entering the noun.
	
Understand "descend [a staircase]" as entering.


[Porch doors]
[
A porch-door is a kind of door. A porch-door has a supporter called the porch. The porch of a porch-door is usually nothing. A porch-door is always openable. A porch-door is usually closed. A porch-door is never lockable. The specification is "Implements a door which has a porch on one side. The door behaves as if it is on a porch on one side. It actually is not. Use a privately named object to place a fake door on the porch. The 'porch' property must be set to the porch object, and it assumes the porch is actually in one of the rooms connected."

Before going through a porch-door (called the door) (this is the implement porch-door rule):
	if the location of the player is the location of the porch of the door:
		if the player is not on the porch of the door:
			say "(first entering [the porch of the door])";
		if the door is closed:
			say "(first opening [the door])";
			now the door is open;
		if the front side of the door contains the porch of the door:
			Update livelyness between the location of the player and the back side of the door;
			move the player to the back side of the door;
		otherwise:
			Update livelyness between the location of the player and the front side of the door;
			move the player to front side of the door;
	otherwise:
		if the door is closed:
			say "(first opening [the door])";
			now the door is open;
		Update livelyness between the location of the player and the location of the porch of the door;
		move the player to the porch of the door;
	stop the action.
	
Before opening a porch-door (called the door) (this is the must be on porch to open porch-door rule):
	if the location of the player is the location of the porch of the door:
		if the player is not on the porch of the door:
			say "(first entering [the porch of the door])";
			try silently the player entering the porch of the door;
			
Before closing a porch-door (called the door) (this is the must be on porch to close porch-door rule):
	if the location of the player is the location of the porch of the door:
		if the player is not on the porch of the door:
			say "(first entering [the porch of the door])";
			try silently the player entering the porch of the door;
	
The implement porch-door rule is listed before the intelligently opening doors rule in the before rulebook.
The must be on porch to open porch-door rule is listed before the intelligently opening doors rule in the before rulebook.
The must be on porch to close porch-door rule is listed before the intelligently opening doors rule in the before rulebook.
]	

Before entering a closed container:
	Try opening the noun.
	

Section - Heavy items

[Some items are really heavy. The player can pick them up, but they can't move around while holding them.]

A thing can be heavy. A thing is usually not heavy.
		
The cart is a supporter. It is fixed in place and pushable between rooms. The description is "A simple metal cart. It has four wheels and a handle to push it with.".
Instead of taking the cart:
	Let A be a random room adjacent to the location;
	Let B be the best route from the location to A;
	Say "That sort of defeats the purpose of a cart, doesn't it? You wouldn't be able to carry it, but considering how it has wheels and a handle for pushing it with you shouldn't need to. All you have to do is [link]push it [B][as]push cart [B][end link].".
Instead of pushing the cart to up:
	Say "You give up on that idea as soon you realize what's involved.".
Instead of pushing the cart to down:
	Say "All that would do is make a lot of noise[if the cart encloses a heavy thing (called the hefty thing)] and probably break [the hefty thing][end if].".
Instead of pushing the cart:
	Let A be a random room adjacent to the location;
	Let B be the best route from the location to A;
	Say "You push the cart around. Well, that accomplished a lot. You might [link]push it [B][as]push cart [B][end link] instead.".
		
Check going when the player encloses a heavy thing (called the hefty thing):
	If the cart encloses the hefty thing: [Oh, alright then..]
		Continue the action;
	Otherwise:
		Say "[The hefty thing] is far too heavy to carry around.";
		Stop the action.
		
Instead of entering something when the player encloses a heavy thing (called the hefty thing):
	Say "[The hefty thing] is far too heavy to carry around.".
	

Pushing it through is an action applying to two touchable things.
Understand "push [something] through [something]" as pushing it through.
Instead of pushing something through something:
	Try pushing the noun.

Instead of pushing the cart through something:
	Say "The cart is not going to fit.".
	
Pushing it into is an action applying to two touchable things.
Understand "push [something] into/in [something]" as pushing it into.
Instead of pushing something into something:
	Try pushing the noun.
	
Before pushing the cart into a closed container:
	Try opening the second noun;
	If the second noun is closed:
		Stop the action.
	
Instead of pushing the cart into something:
	Say "The cart is not going to fit.".

Pushing it out is an action applying to one touchable thing.
Understand "push [something] out" as pushing it out.
Instead of pushing something out:
	Try pushing the noun.
	
Instead of pushing the cart out:
	Now the cart is in the location of the cart;
	Now the player is in the location of the cart;

Section - Weather

A room can be sheltered or unsheltered. A room is usually unsheltered.
A weather condition is a kind of thing. A weather condition can be noisy or silent. A weather condition is usually silent. A weather condition has some text called the action text. A weather condition has some text called the sky-description.

Raining is a noisy weather condition with action text "A constant patter of rain falls about you." and sky-description "Thick clouds stream past.". The noise of Raining is "the pitter-patter of raindrops". The description of Raining is "It's a sort of slow soaking, annoying rain that features big fat rain drops, but lots of space between them.".
Understand "rain", "raindrops" as Raining.

Sunny is a silent weather condition with sky-description "The sky is clear and blue."
Overcast is a silent weather condition with sky-description "The sky is a blanket of calm gray clouds."
Tempest is a noisy weather condition with action text "Rain and wind lash out of the sky." and sky-description "Clouds boil and churn across the dome of heaven.". The noise of Tempest is "the crashing of thunder".

The current weather is a weather condition which varies.  The current weather is sunny.

The sky is a backdrop with description "[the sky-description of the current weather]".

To set the current weather to (condition - a weather condition):
	now the current weather is condition.
	
After deciding the scope of the player when the location of the player is unsheltered:
	Place the sky in scope;
	Place the current weather in scope.

Every turn when the location of the player is unsheltered:
	If the current weather is noisy:
		say "[the action text of the current weather][paragraph break]".
		
Section - Additional implicit actions

Before exiting when the player is enclosed by a closed container (called the cont):
	Say "(first opening [the cont])[command clarification break]";
	Try silently opening the cont.
	
Chapter - New actions
	
Section - Hitting and hitting with

Hitting is an action applying to one touchable thing.
Understand the command  "hit" or "attack" or "smack" or "strike" or "punch" or "harm" or "hurt" or "injure" or "kick" or "break" or "knock" as something new.

Understand "hit [something]" as hitting.

Carry out hitting a person:
	Say "You have a strange compulsion to smack [the noun] about a bit. You resist it.";
	Stop the action.
	
Carry out hitting something:
	Say "Smacking [the noun] about might make you feel better, but it wouldn't accomplish much.";
	Stop the action.
	
Hitting it with is an action applying to two touchable things.
Understand "hit [something] with/-- [something preferably held]" as hitting it with.

Check hitting something (called the victim) with something (called the weapon):
	If the player does not enclose the weapon:
		Say "(first taking [the weapon])";
		Try the player taking the weapon;
		If the player does not enclose the weapon:
			Stop the action.

Carry out hitting a person with something:
	Say "You have a strange compulsion to smack [the noun] about with [the second noun], but you don't really want to hurt them.";
	Stop the action.
	
Carry out hitting something with something:
	Say "Smacking [the noun] about with [the second noun] might make you feel better, but it wouldn't accomplish much.";
	Stop the action.

Understand the command  "attack" or "smack" or "strike" or "punch" or "harm" or "hurt" or "injure" or "kick" or "break" or "knock" as "hit".
	
Understand "knock on/-- [something] with/-- [something]" as hitting it with.

Instead of hitting an open door with something:
	Say "[The noun] is already open. Not much point in knocking.".	
	
[Add the you-could-knock prompt to door descriptions]
Report examining an openable door (called the portal) (this is the print door status rule):
	If the portal is closed:
		Say "[The the portal] is closed. You could [link]knock on the [the printed name of the portal][as]knock on [the printed name of the portal][end link].".
		
Xyzzying is an action out of world applying to nothing.
Understand "xyzzy" as xyzzying.

Report Xyzzying:
	Say "Stop that.".
	
	
Section - Attach command
	
[Understand the command "attach" as something new.
Understand the command "fasten" as something new.
Attaching it to is an action applying to two touchable things.
Understand "attach [something] to/-- [something]" as attaching it to.
Understand the command "tie" as something new.
Understand the command "connect" or "tie" or "hook" as "attach".]

Understand the command "connect" or "hook" as "tie".

First check tying something to something:
	Say "There doesn't seem to be any way to attach [the noun] to [the second noun].";
	Rule fails.
	
Section - Default implementation of remove verb blows

Before taking off something:
	If the player wears the noun, continue the action;
	Otherwise try taking the noun instead.
	
	
Section - Prying

The prybar is a thing with description "This is a slightly curved length of metal with two wicked teeth at one end and a sort of chisel at the other. It's covered in flaking red paint and looks like it would be very useful for prying things open."

Understand the command "pry" as something new.

Prying it with is an action applying to two things.
Understand "pry [something] open/-- with [something preferably held]" as prying it with.
Understand "pry [something] with [something preferably held]" as prying it with.

Implicit-prying is an action applying to one thing.
Understand "pry [something] open/--" as implicit-prying.
Understand "pry [something]" as implicit-prying.

Check prying it with (This is the default block prying rule):
	If the second noun is not the prybar:
		Say "[The second noun] is not such a great tool for prying. A prybar, however, is perfect. It's got 'pry' right there in the name!";
	Otherwise:
		Say "There's not really anything to pry.";
	Stop the action.
	
Check implicit-prying:
	If the player carries the prybar:
		Try prying the noun with the prybar instead;
	Say "You're going to need something to pry it open with. Your hands just aren't going to cut it.";
	Stop the action.
	
Instead of prying a door with the prybar:
	If the tree door is unlocked:
		Say "It's already unlocked. Do you really need to break it too?";
	Otherwise:
		Say "What are you, some kind of vandal? Suffice to say, ripping open doors with a prybar is sending a very bad message, so you decide not to follow through on your impulsive desires.".

Section - Digging

The shovel is a thing with description "This is an ordinary shovel with a wooden handle and a steel blade. It looks like it's seen quite a bit of use. You could use it to [command]dig[normal].".

Understand the command "dig" as something new.

Digging is an action applying to nothing.
Understand "dig" as digging.
The digging action has an object called the buried item found.
The digging action has a room called the location dug in.

Digging with is an action applying to one thing.
Understand "dig with/-- [something]" as digging with.

Setting action variables for digging:
	Now the location dug in is the location of the actor;
	If the number of things buried in the location dug in is not 0:
		Now the buried item found is a random thing buried in the location dug in;
		

Check an actor digging (this is the can't dig without shovel rule):
	If the actor encloses the shovel:
		Continue the action;
	Otherwise:
		Say "You could dig with your hands, you suppose. But you'd rather not get them dirty. What you really need is a shovel.";
		Stop the action.
		
Check an actor digging when the location of the actor is not holey (this is the deny digging in unholey rooms rule):
	Say "There doesn't seem to be anywhere here that you could dig, or at least, no spot that would be improved by adding a hole to it.";
	Stop the action.
	
Check digging with something:
	If the noun is not the shovel:
		Say "That's not going to be very useful for digging. Now, a shovel, that would be handy.";
		Stop the action;
	Try digging instead.
	
Being buried in relates various things to one room.
The verb to be buried in implies the being buried in relation.
	
Carry out an actor digging (this is the unbury the found item rule):
	If the buried item found is not nothing:
		Unbury the buried item found in the location dug in.
		
Report an actor digging (this is the default report digging rule):
	If the buried item found is not nothing:
		Say "You sink the shovel into the earth. After a few moments, you reveal [the buried item found].";
	Otherwise:
		Say "You sink the shovel into the earth, but find nothing of interest.".
	
A room can be holey. A room is usually not holey.

To bury (the item - a thing) in (holey place - a room):
	Now the item is buried in the holey place;
	Remove the item from play.
	
To unbury (the item - a thing) in (the holey place - a room):
	Now the item is not buried in the holey place;
	Now the item is in the holey place;
	
The dig action is a global hyperlink action with printed name "dig" and command text "dig".
Action fruitful rule for the dig action:
	If the location of the player is not holey, rule fails;
	If the player does not enclose the shovel, rule fails.
	

Section - Listen

A thing has some text called the noise. The noise of a thing is usually "".
A room has some text called the ambient noise. The ambient noise of a room is usually "".

The block listening rule is not listed in any rulebook.

Report listening to something:
	If the noise of the noun is "":
		Say "[The noun] makes no discernible sound.";
	Otherwise:
		Say "You hear [the noise of the noun].";
	Stop the action.
	
Report listening:
	Let noise descriptions be a list of text;
	If the ambient noise of the location of the player matches the regular expression "^$":
		Do nothing;
	Otherwise:
		Add the ambient noise of the location of the player to noise descriptions;
	If the location of the player is unsheltered:
		If the noise of the current weather matches the regular expression "^$":
			Do nothing;
		Otherwise:
			Add the noise of the current weather to noise descriptions;
	Repeat with item running through things in the location of the player:
		If the noise of item matches the regular expression "^$":
			Do nothing;
		Otherwise:
			Add the noise of item to noise descriptions;
	If the number of entries in noise descriptions is 0:
		Say "You hear nothing of importance.";
	Otherwise:
		Say "You hear [noise descriptions].".
		
		
Section - Nicer responses to stupid actions

Instead of singing:
	Say "But, but, people might [italic]hear[normal] you!".
	
	
A bed is a kind of supporter. A bed is usually enterable.

Instead of jumping:
	If the player is yourself:
		If a bed encloses the player:
			Say "You bounce on the bed. What fun!";
		Otherwise:
			Say "Athleticism is not in your jeans. Also you're wearing a skirt.";
	Otherwise if the player is Franklin:
		Say "What? No!";
	Otherwise if the player is Spider:
		Say "You put those oddly youthful legs of yours to use and leap in the air like a gazelle! Too bad you forgot you were in a cave! Now you've got a lump on your head.".
	
Instead of waving hands:
	If the location of the player encloses a person:
		Let the waver be a random person enclosed by the location of the player;
		Say "You wave. [If the waver is yourself]Nobody[otherwise][The waver][end if] waves back. It is very awkward.";
	Otherwise:
		Say "You wave. There is nobody here to wave back. Why did you bother?".
		
Instead of thinking:
	Say "[one of]You think about all the wonderful things you would be doing if you weren't on this horrible island. Like eating cheese. Have you seen any cheese on this island? No. You have not.[or]You take a moment to think about your dead parents. And how lucky they are not to be here.[or]You think about some random thing. Does it really matter what?[cycling]".
	
Section - Liquids, vessels, and pouring


A fluid container is a kind of thing. 
A fluid container can be noisy or silent. A fluid container is usually noisy.
Liquid is a kind of value. The liquids are no-liquid, gasoline, amber liquid, wine, and holy water.
A fluid container has a liquid. 

Carry out examining a fluid container (this is the say what's in a fluid container rule):
	If the noun is empty:
		Say "The [the printed name of the noun] is empty";
	Otherwise:
		Say "The [the printed name of the noun] contains [liquid of the noun].".
The say what's in a fluid container rule is listed after the examine undescribed things rule in the carry out examining rulebook.
		
Before printing the name of a fluid container (called the target) while not pouring:
	if the target is empty and the target is noisy:
		say "empty ";
	otherwise: 
		do nothing. 

After printing the name of a fluid container (called the target) while not examining or pouring: 
	[unless the target is empty or the target is silent:
		say " of [liquid of the target]";]
	Omit contents in listing.

Instead of inserting something into a fluid container: 
	say "[The second noun] has too narrow a mouth to accept anything but liquids." 

Definition: a fluid container is empty if the liquid of it is no-liquid.
Definition: a fluid container is full if the liquid of it is not no-liquid.

[
Understand "drink from [fluid container]" as drinking. 


Instead of drinking a fluid container: 
    if the noun is empty: 
        say "There is no more [liquid of the noun] within." instead; 
    otherwise: 
        decrease the current volume of the noun by 0.2 fl oz; 
        if the current volume of the noun is less than 0.0 fl oz, now the current volume of the noun is 0.0 fl oz; 
        say "You take a sip of [the liquid of the noun][if the noun is empty], leaving [the noun] empty[end if]." 


We have allowed all liquids to be drunk, but it would be possible also to add checking, if we had a game where some liquids were beverages and others were, say, motor oil. 
]

Understand the command "fill" as something new. 
Understand "pour [fluid container] in/into/on/onto [fluid container]" as pouring it into. Understand "empty [fluid container] into [fluid container]" as pouring it into. Understand "fill [fluid container] with/from [fluid container]" as pouring it into (with nouns reversed). 

Understand "pour [something] in/into/on/onto [something]" as pouring it into. Understand "empty [something] into [something]" as pouring it into. Understand "fill [something] with/from [something]" as pouring it into (with nouns reversed). 

Pouring it into is an action applying to two things. 

Check pouring it into: 
	if the noun is not a fluid container:
		say "You can't pour [the noun]." instead; 
	if the second noun is not a fluid container:
		say "You can't pour liquids into [the second noun]." instead; 
	if the noun is the second noun:
		say "You can hardly pour [the noun] into itself." instead; 
	if the noun is empty:
		say "There is nothing in [the noun]." instead; 
	if the second noun is full:
		say "[The second noun] cannot contain any more than it already holds." instead;
	if the liquid of the noun is not the liquid of the second noun:
		If the second noun is empty:
			Now the liquid of the second noun is the liquid of the noun; 
			Now the liquid of the noun is no-liquid;
		otherwise:
			say "Mixing [the liquid of the noun] with [the liquid of the second noun] would give unsavory results." instead; 

Report pouring it into: 
	Say "[The noun] is now empty, and [the second noun], full of [the liquid of the second noun].";


[This is probably a drier description than we would actually want in our story, but it does allow us to see that the mechanics of the system are working, so we'll stick with this for the example. 


Now we need a trick from a later chapter, which allows something to be described in terms of a property it has. This way, the story will understand not only "pitcher" and "glass" but also "pitcher of lemonade" and "glass of milk" -- and, indeed, "glass of lemonade", if we empty the glass and refill it with another substance: ]

Understand the liquid property as describing a fluid container. Understand "of" as a fluid container. 

Instead of inserting a fluid container into a fluid container:
	Try pouring the noun into the second noun.


Section - Climbing Through

Understand "climb through [something]" as climbing.

Chapter - 'Useless' items

[A useless item is something that has no purpose to any puzzle. It exists for color. Often times they are duplicate items.]

[
A useless item is a kind of thing. 
Instead of taking a useless item:
	Say "Taken.[paragraph break]On second thought, you don't think there's any point to carrying around [the noun], so you put it back.".
			

The empty can is a kind of useless item with description "An empty can. The label is too far worn to tell what once was in it.".
The plate is a kind of useless item with description "A plain stoneware plate.".
The china cup is a kind of useless item with description "An ornately painted and dainty china tea cup.".
]

[Useless items were removed because the player tried to interact with them too much. Possibly because of the only interactive things are present trope.]

Chapter - Backdrops and topics

The lighthouse is a familiar backdrop. Understand "house" as the lighthouse.
The description of the lighthouse is "[If the location of the player is ghostly]The lighthouse is painted in alternating bands of red and white. At the top, there is a metal walkway.[otherwise]The stripes on the lighthouse are very nearly obscured by the grime covering it's sides. There is a precarious walkway around the top of it.[end if][If the lighthouse is blazing] It is shining brightly.[end if]".
Does the player mean quizzing someone about the lighthouse: It is very likely.
Does the player mean implicit-quizzing the lighthouse: It is very likely.

The subject-dolphins is a subject. Understand "dolphin" and "dolphins" as the subject-dolphins.

Akkoteaque is a familiar privately-named backdrop. Akkoteaque is proper-named. Understand "island", "akkoteaque", "akko", "teaque" as Akkoteaque.

The surf below is a backdrop with description "You would really rather not look down, but you can't resist a glance at the waves crashing on the rocks far below. You immediately regret this decision.".

The waves are a backdrop with description "Long, low, steady waves.".

The ghosts is an unfamiliar subject. Understand "ghost" as the ghosts.

The backdrop-sea is a familiar backdrop. Understand "sea" as the backdrop-sea.

After deciding the scope of the player when the location of the player is unsheltered:
	Place the lighthouse in scope.
	
The subject-treasure is an unfamiliar subject with printed name "treasure". Understand "treasure" as the subject-treasure.

The subject-mother is a familiar proper-named subject with printed name "your mother". Understand "mother", "your mother", "mom", "my mother" as the subject-mother.
The subject-father is a familiar proper-named subject with printed name "your father". Understand "father", "your father", "dad", "my father" as the subject-father.

The subject-accident is a familiar subject with printed name "accident". Understand "accident" as the subject-accident.

Delmarva is a familiar subject.

Chapter - Ciphers

To say cipher:
	(- glk_set_style(style_Subheader); -)
	
To say usd:
	Say "[unicode 160][unicode 160]".
	
To say usq:
	Say "[unicode 160][unicode 160][unicode 160][unicode 160]".

The cipher-fox is some text which varies.
The cipher-fox is "[cipher][fixed letter spacing]┌─┬┐  ┌┬┴┘  ┌─┼┐  ┌──┘  ┌┬┴┘  [line break]├┬─┤  ├─┴┘  ├┬┴┤  ├┬┬┤  ├─┴┘  [line break]└─┴┐  └─┬┘  ├┬─┐  ├┬─┤  └─┬┘  [line break]            ├┬┬┐  ├┬┼┘        [line break]      ┌─┼┤  └┬┴┐  └┬─┘  ┌┬┬┘  [line break]      ├──┐              ├┬┴┤  [line break]      ├┴─┘  ┌┬─┤  ┌─┬┤  ├─┴┤  [line break]      └┴─┐  ├┬┼┐  ├┬─┤  ├──┤  [line break]            ├─┬┘  └┬┼┤  └─┼┘  [line break]            └┬┬┤              [line break][variable letter spacing][normal]".

The cipher-dead is some text which varies.
The cipher-dead is "[cipher][fixed letter spacing]┌─┬┐  ┌──┐  ┌┴─┐  [line break]├─┬┘  ├┬┬┤  ├┬─┤  [line break]├──┐  └─┬┘  └┬┴┤  [line break]└─┬┐              [line break][variable letter spacing][normal]".

The cipher-turn-it-off is some text which varies.
The cipher-turn-it-off is "[cipher][fixed letter spacing]┌┬─┤  ┌─┴┤  ┌┬┴┘  [line break]├─┬┤  └┬┴┘  ├┬┴┤  [line break]└─┬┤        ├┬┬┤  [line break]            └┬─┘  [line break][variable letter spacing][normal]".

The cipher-waiting is some text which varies.
The cipher-waiting is "[cipher][fixed letter spacing]┌┬┴┐  ┌┬─┤  ┌┬─┤  ┌┬┼┘  ►─┴┤  [line break]├─┴┤  ├┬┴┘  └┬─┘  ├──┐        [line break]├─┬┐  ├─┴┘        ├─┴┤  ┌──┐  [line break]└─┬┘  ├─┬┘  ┌┬┴┘  ├┬┴┘  └┬─┐  [line break]      └┬┬┤  ├─┴┘  ├─┴┤        [line break]            └─┬┘  ├┬─┘        [line break]                  └─┴┐        [line break][variable letter spacing][normal]".

The cipher-hand is some text which varies.
The cipher-hand is "[cipher][fixed letter spacing]┌─┴┘  ┌┬─┐  ┌┬┴┘  [line break]├──┐  └┴─┐  ├──┐  [line break]├┬─┘        ├─┼┘  [line break]└─┬┐        └─┬┘  [line break][variable letter spacing][normal]".

The cipher-wake is some text which varies.
The cipher-wake is "[cipher][fixed letter spacing]┌──┤  ┌┬┴┤  ┌┬┼┘  [line break]├─┴┘  └┬┬┐  ├──┐  [line break]├─┴┤        ├─┼┘  [line break]├─┼┤        └─┬┘  [line break]└─┬┐              [line break][variable letter spacing][normal]".

The cipher-abc is some text which varies.
The cipher-abc is "[cipher][fixed letter spacing]►┬┴┤  ►┬┬┐  ►─┼┘  ►─┬┤  ►──┐  [line break]                              [line break]►┬┼┐  ►┬┬┘  ►─┼┤  ►─┴┐  ►──┘  [line break]                              [line break]►┬┼┘  ►┬┬┤  ►┬─┐  ►─┴┘  ►──┤  [line break]                              [line break]►┬┼┤  ►┬┴┐  ►┬─┘  ►─┴┤  ►─┬┐  [line break]                              [line break]►┴─┐  ►┬┴┘  ►┬─┤  ►─┼┐  ►─┬┘  [line break]                              [line break]►┴─┘                          [line break][variable letter spacing][normal]".


Chapter - Puzzle components

Section - Fuses and Circuits

A fuse is a kind of thing. A fuse can be glowing. A fuse is usually not glowing.
A circuit is a kind of container. 

Completes relates various fuses to various circuits. 
The verb to complete (he completes, they complete, he completed, it is completed, he is completing) implies the completes relation.

Definition: A circuit (called the circuit) is complete:
	If the circuit encloses something which completes the circuit:
		yes;
	Otherwise:
		no.
	
After printing the name of a fuse (called the fuse):
	If the fuse is glowing:
		Say "(glowing faintly)".
		
Check inserting a fuse (called the fuse) into a circuit (called the circuit):
	If the circuit encloses a fuse:
		Say "There is already something in there.";
		Stop the action.
		
Check inserting something into a circuit:
	If the noun is not a fuse:
		Say "That's not going to fit in there.";
		Stop the action.
		
After inserting a fuse (called the fuse) into a circuit (called the circuit):
	Say "You slide [the fuse] into [the circuit].";
	If the fuse completes the circuit:
		Say "The fuse begins to glow.";
		Now the fuse is glowing.
	
After taking a fuse (called the fuse):
	If the fuse is glowing:
		Say "The glow fades from the fuse.";
		Now the fuse is not glowing;
	Continue the action.
	


Section - Bracelet and charms

The bracelet is a wearable keychain. Elizabeth wears the bracelet. The description of the bracelet is "A silver charm bracelet of braided cord.[If nothing is enclosed by the bracelet] There aren't any charms on it.[end if]".
Instead of putting a thing on the bracelet:
	If the noun is a charm:
		Continue the action;
	Otherwise:
		Say "That isn't going to work.".

A charm is a kind of passkey. A charm is wearable.
The fire hydrant charm is a hidden charm. The description is "A small gold fire hydrant.".
The lighthouse charm is a hidden charm. The description is "A small pewter lighthouse.". 
The hook charm is a charm. The description is "A small brass fishing hook.".
The thimble charm is a charm. The description is "A small silver thimble.".
The pelican charm is a charm. The description is "A tiny pelican wrought in gold.".
The slipper charm is a charm. The description is "A tiny silver ballerina slipper.".

To decide if the bracelet is complete:
	If the fire hydrant charm is not on the bracelet, decide no;
	If the lighthouse charm is not on the bracelet, decide no;
	If the hook charm is not on the bracelet, decide no;
	If the thimble charm is not on the bracelet, decide no;
	If the pelican charm is not on the bracelet, decide no;
	If the slipper charm is not on the bracelet, decide no;
	Decide yes.
	
Check taking a passkey (called the key):
	If the player does not enclose the key:
		If a keychain (called the chain) encloses the key:
			Say "(taking [the chain] instead)";
			Try taking the chain;
			Stop the action;
		
Before wearing something (called the item):
	If the item is a charm:
		If the player wears the bracelet:
			Try putting (the item) on bracelet;
			Stop the action.
		
Instead of tying something to the bracelet:
	Try putting the noun on the bracelet.
	

Section - Ghostlyness and livelyness

A room can be ghostly or lively. A room is usually ghostly.
The lively weather is a weather condition that varies. The lively weather is raining.
		
Definition: a thing is lively:
	If the location of it is lively, decide yes;
	Decide no.
	
Definition: a thing is ghostly:
	If the location of it is lively, decide no;
	Decide yes.
		
The upon becoming ghostly rules are an object based rulebook.
The upon becoming lively rules are an object based rulebook.

Upon becoming ghostly of the player:
	Set the current weather to sunny.
Upon becoming lively of the player:
	Set the current weather to the lively weather.
	
Upon becoming ghostly of a room (called the room):
	Repeat with item running through things enclosed by the room:
		Consider the upon becoming ghostly rules for item;
	Continue the action.
		
Upon becoming lively of a room (called the room):
	Repeat with item running through things enclosed by the room:
		Consider the upon becoming lively rules for item;
	Continue the action.
		
To update livelyness between (source - a room) and (dest - a room):
	[Say "(Projector going code. From: [source] To: [dest] Loc: [location of the player])";]
	If the player encloses the projector:
		If the projector is switched on:
			Now the dest is lively;
			Consider the upon becoming lively rules for the dest;
			Now the source is ghostly;
			Consider the upon becoming ghostly rules for the source;
	Otherwise:
		If the dest is lively:
			Repeat with item running through things enclosed by the player:
				Consider the upon becoming lively rules for item;
		Otherwise if the source is lively:
			Repeat with item running through things enclosed by the player:
				Consider the upon becoming ghostly rules for item.

Carry out going:
	Update livelyness between the room gone from and the room gone to;
	Continue the action.
	
Section - The projector

The projector is a portable device. The printed name is "strange projector". The description is "This device looks like an old video projector, except that someone has bolted all sorts of odd tubing and dials onto it in some random fashion.[if the projector is switched on] Curiously, while the projector is making all sorts of clicks and clats, it doesn't seem to actually be projecting anything. There's a big purple switch hanging off the side of it.[end if]".
A thing called the odd tubing is part of the projector. The description is "Random bits of tubing, mostly brass. There's also some rubber parts. You can't imagine what it's for.".
A thing called the odd dials are part of the projector. The description is "You can't make any sense of the dials. This is probably because none of them are labelled.".
The noise of the projector is "[If the projector is switched on]the click-clack of the projector chugging away[end if]".
Understand "etho", "etho-projectofier", "projectofier", "strange", "strange projector" as the projector.

Rule for writing a paragraph about the projector when the projector is switched on:
	Say "[A projector] sits here, clattering away.".
			
To deactivate the projector:
	Now the location of the projector is ghostly;
	If the projector is switched on:
		Now the projector is switched off;
		Consider the upon becoming ghostly rules for the location of the projector;
		If the location of the projector is the location of the player:
			Say "The projector stops with a sputter. Your surroundings shimmer for a moment, and then appear to be returned to normal.".
	
To activate the projector:
	Now the location of the projector is lively;
	If the projector is switched off:
		Now the projector is switched on;
		If the location of the projector is the location of the player:
			Say "The projector hums to life. Your surroundings shimmer for a moment, and then take on a neglected air.";
		Consider the upon becoming lively rules for the location of the projector.

		
Instead of switching on the projector:
	If the projector is switched on:
		Say "The projector is already on.";
	Otherwise:
		Say "You switch on the projector.";
		Activate the projector;
		Try the player looking.
		
Instead of switching off the projector:
	If the projector is switched on:
		Say "You switch off the projector.";
		Deactivate the projector;
		Try the player looking;
	Otherwise:
		Say "It isn't on anyway.".
		
Instead of hitting the projector:
	Say "You give the projector a smack.";
	If the projector is switched on:
		Deactivate the projector;
		Try the player looking;
	Otherwise:
		Activate the projector;
		Try the player looking.
		
Instead of hitting the projector with the wrench:
	Say "Smashing the projector to bits is probably not a good idea.".
	
Section - Testing Livelyness - Not For Release

Listing lively items is an action out of world applying to nothing.
Understand "lively" as listing lively items.

Carry out listing lively items:
	Say "These are all the currently lively items:[line break]";
	Repeat with I running through every lively room:
		Say "  [I] (a room)[line break]";
	Repeat with I running through every lively thing:
		Say "  [I][line break]".

Section - Ladder

The ladder is a portable enterable supporter.
Instead of climbing the ladder, try entering the ladder.
Report entering the ladder: say "You clamber up the ladder." instead. 
Instead of entering the ladder when the player encloses the ladder: 
	Try dropping the ladder;
	Try entering the ladder.
Instead of using the ladder:
	Try entering the ladder.
Instead of going down when the player is on the ladder:
	Try getting off the ladder.
	

Climb-The-Ladder is a global hyperlink action with printed name "climb the ladder" and command text "climb ladder".
Action fruitful rule for Climb-The-Ladder:
	If the player encloses the ladder, rule succeeds;
	If the location of the player encloses the ladder, rule succeeds;
	Rule fails.
	
A room can be ladder-accessible. A room is usually not ladder-accessible. [A ladder accessible room requires using the ladder to reach it.]
The ladder accessibility rules are an object based rulebook with default success.
The last ladder accessibility rule:
	Rule succeeds.
A room has a room called the ladder accessibility point.

Section - Elevator and associated items

The elevator is a transparent openable lockable enterable fixed in place container. The elevator is closed. The elevator is locked. The description of the elevator is "The elevator has metal mesh sides, likely to keep you from falling out.[If the elevator is closed] The elevator is closed.[end if]".
Understand "mesh" as the elevator.
The green button is a fixed in place thing inside the elevator. The description of the green button is "It's an ordinary little round button.".
Instead of taking the elevator:
	Say "You can't very well carry the elevator. Generally, as far as elevators are concerned, it happens the other way around.". 
Rule for printing the name of the elevator while looking:
	Say "[interest]elevator[normal]";
	omit contents in listing.
		
Instead of pushing the cart into the elevator:
	Now the cart is in the elevator;
	Now the player is in the elevator;
	
Instead of inserting a heavy thing into the elevator:
	Say "[The noun] is far too heavy to carry around.".
	
Before going when in the elevator (this is the exit the elevator before going rule):
	If sequential action option is active:
		Try the player exiting;
	Otherwise:
		Say "(first exiting the elevator)[command clarification break]";
		Silently try the player exiting;
	If the elevator encloses the player:
		Stop the action.
		
Before exiting when in the elevator (this is the open the elevator before exiting rule):
	If the elevator is open:
		Continue the action;
	If sequential action option is active:
		Try the player opening the elevator;
	Otherwise:
		Say "(first opening the elevator)[command clarification break]";
		Silently try the player opening the elevator;
	If the elevator is closed:
		Stop the action.

The exit the elevator before going rule is listed first in the before rules.
The open the elevator before exiting rule is listed first in the before rules.	

Instead of climbing the ladder when in the elevator:
	Say "The elevator isn't tall enough to climb the ladder in it.".
Before taking something (called the item) when in the elevator:
	If the item is not enclosed by the elevator:
		Say "(first opening the elevator)[command clarification break]";
		Silently try the player opening the elevator.

The iron key is a passkey. The iron key unlocks the elevator. The description of the iron key is "An old fashioned barrel and spade style key.".

The green fuse is a fuse. The description is "The fuse is a frosted glass tube with metal caps on each end. One cap is imprinted with the words 'Bloss Brand 420'.[if the green fuse is glowing] It glows faintly.[end if]".
The electrical box is a fixed in place closed openable locked lockable circuit. The description of the electrical box is "It's a little metal box with a lightning bolt on it.[if the electrical box is broken] You broke the lock off.[otherwise] There is a little lock holding it shut. You could unlock it, or just hit it with something.[end if]". 
The electrical box can be broken. The electrical box is not broken.
The electrical box label is a fixed in place thing inside the electrical box. The description is "The label reads 'Replace only with Bloss Brand 420 fuse'.".
The red fuse is a fuse. The description is "The fuse is a frosted glass tube with metal caps on each end. One cap is imprinted with the words 'Bloss Brand 120'.[if the red fuse is glowing] It glows faintly.[end if]".
The green fuse completes the electrical box.
The spent fuse is a fuse. The description is "The fuse is a frosted glass tube with metal caps on each end. The glass has been blackened from the inside.".

The Complete-Box-Action is a hyperlink action with printed name "put the green fuse in the electrical box" and command text "put green fuse in box".
Action fruitful for the Complete-Box-Action:
	If the player does not enclose the green fuse:
		Rule fails.
The special actions of the electrical box are { Complete-Box-Action }.

The maintenance key is a passkey with indefinite article "a". The maintenance key unlocks the electrical box. The description of the maintenance key is "A simple and rather plain little key."

The wrench is a thing. The description is "A big heavy wrench.".
Understand "spanner" as the wrench.

Instead of locking the electrical box with the maintenance key when the electrical box is broken:
	Say "It's never going to lock again. You broke it too well.";
Instead of hitting the electrical box with the wrench:
	Now the electrical box is unlocked;
	Now the electrical box is broken;
	Say "You smash the electrical box with the wrench and break the lock. Well, that's one way to get things done.".
Instead of prying the electrical box with the prybar:
	Now the electrical box is unlocked;
	Now the electrical box is broken;
	Say "You jam the pointy end of the prybar between the door of the electrical box and the body. It doesn't take very much force to rip the door open.".
	
	
Instead of pushing the green button:
	If the elevator encloses the player:
		If the electrical box is not complete:
			Say "There is a bit of creaking, and a popping noise, and then nothing at all happens.";
			Stop the action;
		If the elevator is open:
			Try the player closing the elevator;
		If the location of the elevator is the machinery room:
			Say "The elevator rises with some creaking and grinding. After a moment, you arrive at the top of the lighthouse.";
			Now the elevator is in the lighthouse apex;
			Try the player looking;
		Otherwise if the location of the elevator is the lighthouse apex:
			Say "The elevator sinks with some creaking and grinding. After a moment, you arrive at the bottom of the lighthouse.";
			Now the elevator is in the machinery room;
			Try the player looking;
	Otherwise:
		Say "You'd have to be inside the elevator to reach that.".
		

Section - The pocket watch and mausoleum

The pocket watch is a closed openable container with description "This worn pocket watch used to be shining brass. Now it's mostly tarnish. It is engraved with the image of an owl on one side and your father's initials on the reverse.[If the pocket watch is open] Tucked under the lid is a picture of you. Your father kept it there. The watch reads precisely [the set time of the watch].[otherwise] The watch is closed, so you can't read it.[end if]".
The player carries the pocket watch.

The pocket watch has a time called the set time. The set time of the pocket watch is 1:56 pm.
The pocket watch can be ticking or stopped. The pocket watch is ticking.

The noise of the pocket watch is "[if the pocket watch is ticking]a steady tick tick tick[end if]".

Instead of inserting something into the pocket watch:
	Say "It's a watch, not a bucket.".

Instead of dropping the pocket watch:
	Say "There's a certain sentimental value attached to this watch. It belonged to your father, after all. You decide to hang onto it.".

The tiny-picture is a privately-named thing with description "It's a wallet-sized picture of you. It's a couple of years old so it's not really a good representation of you anymore. For example, in the picture you appear rather happy.".
The tiny-picture is in the pocket watch.
The printed name of the tiny-picture is "tiny picture".
Understand "tiny", "picture", "tiny picture" as the tiny-picture.

Instead of taking the tiny-picture:
	Say "It's tucked behind a piece of glass in the lid of the watch. You don't think you could get it out without breaking the watch.".
	
Every turn when the watch is ticking:
	Now the set time of the watch is 1 minute after the set time of the watch.
		
Time-Setting it to is an action applying to one thing and one time.
Understand "set [something] to [time]" as time-setting it to.

Carry out time-setting something to (this is the default refusal to set things to times rule):
	Say "It doesn't seem to be possible to set [the noun] to a time.".
	
Instead of time-setting the watch to (this is the set the watch rule):
	If the pocket watch is ticking, say "It's already set to the right time.";
	Otherwise say "The little knob won't turn.".
	
To stop the pocket watch:
	Now the pocket watch is stopped;
	If the set time of the mausoleum clock is the set time of the pocket watch:
		Now the set time of the mausoleum clock is (6 hours 17 minutes before the set time of the pocket watch).
		
The mausoleum is a fixed in place locked lockable enterable container. The description of the mausoleum is "A small granite building, the mausoleum shows the years it has weathered with pride. It has columns at each corner, and reliefs of angels and such on the sides, and a stone clock right above the [link]door[as]x door[end link]. The stone [link]clock[as]x clock[end link] reads [the set time of the mausoleum clock].".
The mausoleum door is a part of the mausoleum. The description of the mausoleum door is "In big bold letters across the door is the name 'Magdeline'.".
The mausoleum clock is a part of the mausoleum. The description of the mausoleum clock is "You can just barely make out the numbers on this worn rock face. Upon close inspection, it's apparent that the hands aren't just carved on the clock face. They could actually move. You could set the clock to any time you wish.". 
The mausoleum clock has a time called the set time. The set time of the mausoleum clock is 11:22 am.

Instead of entering the mausoleum door:
	Try entering the mausoleum.
Instead of opening the mausoleum door:
	Try opening the mausoleum.
Instead of closing the mausoleum door:
	Try closing the mausoleum.

Instead of time-setting the mausoleum clock to (this is the set the mausoleum clock rule):
	Now the set time of mausoleum clock is the time understood;
	If the set time of mausoleum clock is the set time of the pocket watch:
		Say "You set the clock to [the time understood]. There is an audible click.";
		Now the mausoleum is unlocked;
	Otherwise:
		Say "You set the clock to [the time understood].";
		Now the mausoleum is locked.
		
Instead of unlocking keylessly the mausoleum:
	Say "There doesn't seem to be any sort of key hole.".
	
Chapter - Fishing

Section - The Pole

The fishing pole is a hidden thing.
The fishing pole has an object called the attached hook. The attached hook of the fishing pole is the rusty hook.
The fishing pole has an object called the attached bait. The attached bait of the fishing pole is nothing.

After deciding the scope of the player when the location of the player encloses the fishing pole (This is the put the hook in scope rule):
	If the attached hook of the fishing pole is not nothing, place the attached hook of the fishing pole in scope.
	
The fishing line is a part of the fishing pole. The description is "It's rather ordinary plastic line.".
	
After printing the name of the fishing pole:
	Say " (with [run paragraph on]";
	If the attached hook of the fishing pole is not nothing:
		Say "[the attached hook of the fishing pole][run paragraph on]";
		If the attached bait of the fishing pole is not nothing, say " and [the bait-name of attached bait of the fishing pole][run paragraph on]";
	Otherwise:
		Say "no hook at all";
	Say ")";
	
The description of the fishing pole is "[fishing-pole-details]".
To say fishing-pole-details:
	Say "This is a basic fishing pole. You can [link]cast[end link] it anywhere you find a body of water. When a fish bites, [link]reel[end link] it in. You could try different hooks, just tie them on. There are also different kinds of bait. Try baiting the hook with something.[run paragraph on]";
	If current-fishing-state is not-fishing:
		If the attached hook of the fishing pole is not nothing:
			Say " There is [attached hook of the fishing pole] on the end of the line[run paragraph on]";
			If the attached bait of the fishing pole is not nothing:
				Say ", baited with [the bait-name of attached bait of the fishing pole].";
			Otherwise:
				Say ".";
		Otherwise:
			Say " There is no hook at all on the end of the line.";
	Otherwise:
		Say " You've cast your fishing line into the sea.";
		
After examining the fishing pole when hyperlinks are currently enabled:
	Let hook-list be a list of objects;
	Let bait-list be a list of objects;
	Repeat with H running through every thing held by the player:
		If H is an acceptable hook, add H to hook-list, if absent;
		If the attached hook of the fishing pole is not nothing and H is acceptable bait, add H to bait-list, if absent;
	If (the number of entries in hook-list is not 0) or (the number of entries in bait-list is not 0), say "You could [run paragraph on]";
	If the number of entries in hook-list is not 0:
		Repeat with A running from 1 to the number of entries in hook-list:
			Say "[link]tie the [the printed name of entry A in hook-list] to the line[as]attach [the printed name of entry A in hook-list] to pole[end link][run paragraph on]";
			If A is not the number of entries in hook-list, say ", [run paragraph on]";
	If the number of entries in bait-list is not 0:
		If the number of entries in hook-list is not 0, say " or [run paragraph on]";
		Repeat with A running from 1 to the number of entries in bait-list:
			Say "[link]bait the line with [the bait-name of entry A in bait-list][as]bait pole with [the printed name of entry A in bait-list][end link][run paragraph on]";
			If A is not the number of entries in bait-list, say ", [run paragraph on]";
	If (the number of entries in hook-list is not 0) or (the number of entries in bait-list is not 0), say ".";
	Continue the action.
		

The special actions of the fishing pole are { cast action, reel action }.
	
The cast action is a hyperlink action with printed name "cast your fishing line" and command text "cast".
Action fruitful rule for the cast action:
	If the player encloses the fishing pole:
		If the current-fishing-state is not-fishing:
			Rule succeeds;
	Rule fails.
		
The reel action is a hyperlink action with printed name "reel in your fishing line" and command text "reel".
Action fruitful rule for the reel action:
	If the player encloses the fishing pole:
		If the current-fishing-state is landed:
			Rule succeeds;
	Rule fails.
	
	

Section - Hooks

The rusty hook is a thing with description "This is your basic rusted old fishing hook. It's good for catching the boring sorts of fish.".
The lure is a thing with description "This flashy little fishing lure is shaped like a tiny fish with hooks instead of fins.".
The sinker is a thing with description "This hook has a big weight on it so it goes straight to the bottom.".
The big hook is a thing with description "This is a big, heavy-duty hook suitable for catching the bigger fish.".
The any-hook is a thing.

The acceptable hooks is a list of things that varies. The acceptable hooks are { rusty hook, hook charm, lure, sinker, big hook }.

To decide if (item - a thing) is an acceptable hook:
	If item is listed in acceptable hooks, decide yes;
	Decide no.
	
Section - Bait
	
A bait is a kind of thing.
A bait has some text called the bait-name. The bait-name of a bait is usually "[the printed name]".

To decide if (item - a thing) is acceptable bait:
	If item is a bait, decide yes;
	Decide no.
	
The fish-head is a bait with bait-name "a bit of fish head". The description is "The half digested head of a fish that [the shoo] very nearly puked on you.". The printed name is "fish head". Understand "fish", "head", "fish head" as the fish-head.
The worm is a bait with bait-name "a bit of worm". The description is "A wiggly little worm.".
The loaf of bread is a bait. The description is "[If ghostly]A loaf of stale bread.[otherwise]A loaf of moldy bread.[end if]". The bait-name is "a bit of bread".
The clam is a bait with bait-name "a chunk of clam". The description is "A clam you dug out of the jetty.".
The any-bait is a bait.

Instead of eating the loaf of bread:
	If the loaf of bread is ghostly, say "It's really quite stale and unappetizing.";
	Otherwise say "It's covered in mold. Disgusting!".
	
Section - Preparing to Fish

Instead of putting something (called the item) on the fishing pole:
	Try the player tying the item to the fishing pole.
Instead of putting something on the fishing line:
	Try tying the noun to the fishing pole.
Instead of tying something to the fishing line:
	Try tying the noun to the fishing pole.
	
Instead of tying something (called the item) to the fishing pole:
	If the current-fishing-state is not not-fishing, say "You'll have to stop fishing first." instead;
	If the item is the attached hook of the fishing pole, say "You're already using that as a hook." instead;
	If the item is the attached bait of the fishing pole, say "You're already using that as bait." instead;
	If the item is an acceptable hook:
		Say "You tie [the item] to the end of your fishing line.";
		If the attached hook of the fishing pole is not nothing:
			Now the player holds the attached hook of the fishing pole;
		Now the attached hook of the fishing pole is the item;
		Remove the item from play;
	Otherwise if the item is acceptable bait:
		If the attached hook of the fishing pole is nothing, say "There's no hook on the line for you to bait." instead;
		Now the attached bait of the fishing pole is the item;
		Say "You bait [the attached hook of the fishing pole] with [the bait-name of item].";
	Otherwise:
		Say "That won't work as fishing tackle.".
		
Baiting it with is an action applying to two things. Understand "bait [something preferably held] with [something preferably held]" as baiting it with.

Before baiting something with something:
	If the noun is the attached hook of the fishing pole, try tying the second noun to the fishing pole instead;
	If the noun is not the fishing pole, say "That isn't the fishing pole.";
	Otherwise try tying the second noun to the noun instead.
		
Before taking something (this is the remove hook from the fishing pole first rule):
	If the noun is the attached hook of the fishing pole:
		Now the attached hook of the fishing pole is nothing;
		Now the attached bait of the fishing pole is nothing;
		Now the noun is in the location of the player;
	Continue the action.
	
Before tying something to something (this is the allow tying things to hooks on the line rule):
	If the second noun is the attached hook of the fishing pole, try tying the noun to the fishing pole instead.
	
Before putting something on something (this is the put it on the pole instead rule):
	If the second noun is the attached hook of the fishing pole, try tying the noun to the fishing pole instead.
	
	
Section - The Aquarium

The aquarium is a room.

Instead of giving a fish (called the fish) to Shoo:
	Say "[The shoo] snatches [the fish] from your hands and gobbles it down. That bird has quite an appetite.";
	Now the fish is in the aquarium.


Section - Fish

A fish is a kind of thing. The description of a fish is usually "FISH". A fish is edible. Understand "fish" as a fish. 
A fish can be caught or uncaught. A fish is usually uncaught.
A fish has a number called the fight. The fight of a fish is usually 3.
A fish can be smelled or not smelled. A fish is usually not smelled.
Has-smelled-a-fish is a truth-state that varies. Has-smelled-a-fish is false.

Instead of eating a fish:
	Say "You had sushi once. It was disgusting. You've since learned that raw fish is technically sashimi, not sushi. It's still disgusting.".
	
Instead of smelling a fish (called the smellee):
	If the smellee is smelled:
		Say "It smells the same as the last time: Fishy.";
	Otherwise:
		Now the smellee is smelled;
		If has-smelled-a-fish is true:
			Say "It smells pretty much the same as the last fish you smelled. All fish kind of smell the same, don't they?";
		Otherwise:
			Now has-smelled-a-fish is true;
			Say "It smells about how you expect a fish to smell. That is, fishy.".

A striped bass is a fish in the aquarium with description "This fish has a big fat belly and black dots down it's sides. The dots run in stripes, hence the name. It's dorsal fins are very sharp. It's about two feet long.".
The best hooks of the striped bass are { lure }.
The best baits of the striped bass are { any-bait }.

A bluefish is a fish in the aquarium with description "This fish is green on the back and silver on the belly. It has a stout body, a forked tail, and stripes like a tiger, except in blue. It's about a foot and a half long.".
The best hooks of the bluefish are { any-hook }.
The best baits of the bluefish are { any-bait }.

A mackerel is a fish [in the aquarium] with description "This fish is long and slender with striking black bands. Its silvery scales flash in the sun. It's about a foot long.".
The best hooks of the mackerel are { rusty hook, hook charm }.
The best baits of the mackerel are { nothing, any-bait }.

A flounder is a fish in the aquarium with description "This fish is flat and both it's eyes are on the same side of it's head - the right side. It's a little over a foot long.".
The best hooks of the flounder are { sinker }.
The best baits of the flounder are { worm, clam }.

A rainbow smelt is a fish in the aquarium with description "This is a long slender fish. Iridescent rainbows play across it's scales. It has lots of sharp teeth. It's not even a foot long.".
The best hooks of the rainbow smelt are { rusty hook, hook charm }.
The best baits of the rainbow smelt are { clam, worm }.

A cod is a fish in the aquarium with description "This is a big ugly fish. It's kind of bulbous, and has round fins. It's almost black on top, and white on the belly. It's about three feet long.".
The best hooks of the cod are { lure, big hook }.
The best baits of the cod are { clam, loaf of bread, fish-head }.

A haddock is a fish in the aquarium with description "This is a fat fish with a dark lateral line and large spots over each fin. It looks kind of like a less ugly version of a code. It's about two feet long.".
The best hooks of the haddock are { hook charm, sinker, big hook }.
The best baits of the haddock are { clam, fish-head }.

A pollock is a fish in the aquarium with description "This olive-green fish has a barb sticking out of it's chin. It's sort of an olive-green, and it has a white and black stripe down it's side. It's about a foot long.".
The best hooks of the pollock are { any-hook }.
The best baits of the pollock are { clam, nothing }.

A herring is a fish in the aquarium with description "This is a very long and narrow fish with a small, pointed head. It's blue on top and silver on the belly. It's about a foot and a half long.".
The best hooks of the herring are { any-hook }.
The best baits of the herring are { nothing, any-bait }.

A salmon is a fish in the aquarium with description "This fish has a brown back marked with black spots. It also has a terrible overbite. This is probably a young salmon, because it's only about a foot long.".
The best hooks of the salmon are { rusty hook, hook charm }.
The best baits of the salmon are { nothing, any-bait }.

A brown trout is a fish in the aquarium with description "This little fish has a long head, a protruding lower jaw, and a square tail. As expected, it's more or less brown, but it does have spots. It's less than a foot long.".
The best hooks of the brown trout are { lure }.
The best baits of the brown trout are { worm }.

An ocean pout is a fish in the aquarium with description "This fish is long and skinny, like an eel. It's head is a bit too big, however. It's about two feet long.".
The best hooks of the ocean pout are { big hook }.
The best baits of the ocean pout are { loaf of bread }.

A tautog is a fish in the aquarium with description "This fish has a blunt nose and thick lips. It's dark green all over and incredibly ugly. It's about a foot long.".
The best hooks of the tautog are { sinker }.
The best baits of the tautog are { nothing, any-bait }.

A longhorn sculpin is a fish in the aquarium with description "This fish has spines all around it's nose, head, gills, and fins. It has crossbar markings on it's flank. It's not even a foot long.".
The best hooks of the longhorn sculpin are { rusty hook, hook charm }.
The best baits of the longhorn sculpin are { worm }.

A cunner is a fish in the aquarium with description "This fish has buck teeth. No, really, it's like the tautog's even uglier cousin. It's about half a foot long.".
The best hooks of the cunner are { rusty hook }.
The best baits of the cunner are { nothing, any-bait }.

A shad is a fish in the aquarium with description "This fish ha a sharp saw-edged belly and a deeply forked tail. It's narrow and rather pointed, and silvery. It's about two feet long.".
The best hooks of the shad are { lure }.
The best baits of the shad are { nothing, any-bait }.

A tomcod is a fish in the aquarium with description "This fish is fat and covered in dark mottling. It's sort of like a little pathetic version of a cod. It's about a foot long.".
The best hooks of the tomcod are { rusty hook, hook charm }.
The best baits of the tomcod are { nothing, any-bait }.

A white perch is a fish in the aquarium with description "This fish has spines on it's fins. It's sort of chubby. It's less than a foot long.".
The best hooks of the white perch are { lure }.
The best baits of the white perch are { nothing, any-bait }.

A skate is a fish in the aquarium with description "This fish has a flattened body and large wing-like pectoral fins. It's about two feet long.".
The best hooks of the skate are { sinker, big hook }.
The best baits of the skate are { fish-head }.

A dogfish is a fish in the aquarium with description "This small shark has a slender body and flattened head. It's slate gray, and since it's a shark, has no scales. It's about three feet long.".
The best hooks of the dogfish are { big hook }.
The best baits of the dogfish are { fish-head }.

A monkfish is a fish in the aquarium with description "This fish's head makes up nearly half of it's body! It has an enormous mouth bristling with sharp, curved teeth, and a elongated ray above the eyes that it uses like a lure. It's about two feet long.".
The best hooks of the monkfish are { sinker }.
The best baits of the monkfish are { fish-head, worm, clam }.

A cusk is a fish in the aquarium with description "This fish has dorsal fins that extend the entire length of it's body. It's fins have a narrow black band and white edge. It's about two and a half feet long.".
The best hooks of the cusk are { big hook }.
The best baits of the cusk are { any-bait }.

A redfish is a fish in the aquarium with description "This fish is red and orange. It has large eyes and stuff stiff spines. It looks very old, but it's not even a foot long.".
The best hooks of the redfish are { rusty hook, hook charm }.
The best baits of the redfish are { nothing, any-bait }.

A wolffish is a fish in the aquarium with description "This fish has large teeth and powerful jaws. It has a large head and round fins. It's about two feet long.".
The best hooks of the wolffish are { sinker, big hook }.
The best baits of the wolffish are { fish-head }.



Section - Choosing the best fish

A room has a list of fish called the catchable fish.
A fish has a list of objects called the best hooks. 
A fish has a list of objects called the best baits.

The possible fish is a list of fish that varies.
The choosen fish is an object that varies.

To decide if (item - an object) can catch (fish - a fish):
	If the any-hook is listed in (the best hooks of fish), decide yes;
	If the item is listed in (the best hooks of fish), decide yes;
	Decide no.
	
To decide if (item - an object) attracts (fish - a fish):
	If item is not nothing and the any-bait is listed in (the best baits of fish), decide yes;
	If the item is listed in (the best baits of fish), decide yes;
	Decide no.
	
To decide if a fish can be caught:
	Now the possible fish is { };
	Let L be a list of fish;
	Repeat with F running through the catchable fish of the location of the player:
		If F is in the aquarium, add F to L, if absent;
	Repeat with F running through L:
		If (the attached hook of the fishing pole can catch F) and (the attached bait of the fishing pole attracts F), add F to the possible fish;
	If the number of entries in possible fish is not 0:
		Sort possible fish in random order;
		Now the choosen fish is entry 1 of possible fish;
		Decide yes;
	Decide no.
	
Section - Testing Fishing - Not For Release

Aquarring is an action out of world applying to nothing.
Understand "aquarium" as aquarring.

Carry out aquarring:
	Say "Fish in the aquarium: [list of things in the aquarium]".
	
	
Testing fish locations is an action out of world applying to nothing.
Understand "fishloc" as testing fish locations.

Carry out testing fish locations:
	Repeat with F running through every fish:
		Let L be a list of rooms;
		Now L is { };
		Repeat with R running through every room:
			If F is listed in the catchable fish of R, add R to L, if absent;
		If the number of entries in L is 0:
			Say "[F] - FOUND NOWHERE  [run paragraph on]";
		Otherwise:
			Say "[F] - [L] [run paragraph on]";
		Say "Hookable with: [best hooks of F] Attracted by: [best baits of F][line break]".
		
			

Section - Fishing

A room can be fishable. A room is usually not fishable.

Fishing-state is a kind of value. The fishing-states are not-fishing, casted, and landed.
Current-fishing-state is a fishing-state that varies. Current-fishing-state is not-fishing.
To decide if fishing:
	If current-fishing-state is not not-fishing, decide yes;
	Decide no.
The landed fish is an object that varies. The landed fish is nothing.

To land a fish:
	Say "Something tugs on your line! [link]Reel[as]reel[end link] it in!";
	If a fish can be caught:
		Now the landed fish is the choosen fish;
	Otherwise:
		Now the landed fish is nothing;
	Now current-fishing-state is landed.
	
To lose the fish:
	Say "The fish got away! Too bad.";
	Now the landed fish is nothing;
	Now current-fishing-state is not-fishing.
	
To abort fishing:
	If the current-fishing-state is landed, lose the fish;
	Now the current-fishing-state is not-fishing.
	
Implicit-casting is an action applying to nothing.
Understand "cast" as implicit-casting.
Casting is an action applying to one thing.
Understand "cast [something preferably held]" as casting.
Check casting:
	Say "That's not something you can cast.".
Instead of casting the fishing pole:
	If the player does not enclose the fishing pole:
		Try taking the fishing pole;
	If the player encloses the fishing pole:
		Try implicit-casting.
		
Instead of casting the fishing line:
	If the player does not enclose the fishing pole:
		Try taking the fishing pole;
	If the player encloses the fishing pole:
		Try implicit-casting.

Check implicit-casting:
	If the player does not enclose the fishing pole, say "You don't have a fishing pole to cast." instead;
	If the location of the player is not fishable, say "There doesn't seem to be anywhere here to fish." instead;
	If the attached hook of the fishing pole is nothing, say "There's no hook on your line. What did you expect to catch?" instead.
	
Carry out implicit-casting (this is the implement casting rule):
	If the attached bait of the fishing pole is nothing:
		Say "You don't think you'll catch much without some bait, but it's worth a try. [run paragraph on]";
	Say "You cast your fishing line into the sea.";
	Now current-fishing-state is casted.
	
Before doing anything other than waiting or casting or implicit-casting or reeling or looking or examining when fishing:
	Say "You're going to have to reel your line in first." instead.
	
After waiting when fishing:
	If current-fishing-state is landed:
		Lose the fish;
		Continue the action;
	If a random chance of 1 in 3 succeeds:
		Land a fish;
	Otherwise:
		Continue the action.
		

Reeling is an action applying to one thing.
Understand "reel in [something preferably held]" as reeling.
Understand "reel [something preferably held]" as reeling.
Implicit-reeling is an action applying to nothing.
Understand "reel" as implicit-reeling.

Check reeling:
	Say "That's not something you can reel in.".
Instead of reeling the fishing pole:
	If the player does not enclose the fishing pole:
		Try taking the fishing pole;
	If the player encloses the fishing pole:
		Try implicit-reeling.
Instead of reeling the fishing line:
	If the player does not enclose the fishing pole:
		Try taking the fishing pole;
	If the player encloses the fishing pole:
		Try implicit-reeling.

Check implicit-reeling:
	If the player encloses the fishing pole:
		If the current-fishing-state is not-fishing, say "You aren't fishing." instead;
		If the current-fishing-state is casted:
			Say "Okay, but reeling in your line now just means you'll have to cast it again.";
			Now current-fishing-state is not-fishing;
			Stop the action;
	Otherwise:
		Say "You aren't fishing." instead.
		
Carry out implicit-reeling:
	If the current-fishing-state is landed:
		If the landed fish is nothing:
			Say "You caught some sea-weed! You, uh, throw it back..";
			Now current-fishing-state is not-fishing;
		Otherwise:
			If a random chance of 1 in (the fight of the landed fish) succeeds:
				Say "You caught [a landed fish]!";
				Now the landed fish is caught;
				Now the player holds the landed fish;
				Now current-fishing-state is not-fishing;
				Add the landed fish to the fish caught here of the location of the player, if absent;
				If the landed fish is unexamined:
					Try examining the landed fish;
			Otherwise:
				Say "You reel in some line. The fish is really putting up a fight! Keep [link]reeling[as]reel[end link] it in!".
		
Every turn when fishing:
	If current-fishing-state is casted, say "You are fishing. [link]Wait[as]z[end link] for something to bite!".
	
Section - Fish Score

A room has a list of objects called the fish caught here. The fish caught here of a room are usually { }.
A room has some text called the place name. The place name of a room is usually "[printed name]".

Last Carry out requesting the score:
	Repeat with R running through every visited fishable room:
		If R is not the sea:
			If the number of entries in the fish caught here of R is 0:
				Say "You haven't caught anything [the place name of R].";
			Otherwise:
				Say "You've caught [the fish caught here of R] [the place name of R].";
	If the number of uncaught fish is not 0:
		Prepare a list of every uncaught fish;
		Say "You haven't yet caught [a prepared list delimited in disjunctive style].";
	Stop the action.
		
Chapter - Aspergillum

The aspergillum is a fluid container. The description is "It's a small wand with a ball on the end. The ball has lots of little holes in it.".
The liquid of the aspergillum is holy water.
Understand "holy", "water", "asp", "asper", "gillum" as the aspergillum.

Instead of pouring the aspergillum into something:
	Try sprinkling the aspergillum on the second noun.
Instead of pouring something into the aspergillum:
	Say "The aspergillum has little holes to let holy water out, but you really have no idea how to go about refilling it. It doesn't seem to open anywhere.".
	
Sprinkling it on is an action applying to two things.
Understand "sprinkle [something preferably held] on [something]" as sprinkling it on.
Understand "sprinkle [something] with [something preferably held]" as sprinkling it on (with nouns reversed).

Check sprinkling it on:
	Say "[The noun] isn't something you can sprinkle.".
	
A thing can be holy. A thing is usually not holy. 
Understand the holy property as describing a thing.

Instead of sprinkling the aspergillum on something:
	Say "You sprinkle some holy water on [the second noun]. It doesn't do anything, except in a theological sense.";
	Now the second noun is holy.
	
The holy-mackerel-flag is a truth-state that varies. The holy-mackerel-flag is false.

Instead of sprinkling the aspergillum on the mackerel:
	Say "You sprinkle some holy water on [the second noun]. It doesn't do anything, except in a theological sense.";
	Now the second noun is holy;
	If holy-mackerel-flag is false:
		Award 1 point with message "1 point for blessing a specific sea creature";
		Now holy-mackerel-flag is true.
		

Part - Locations

Section - Outset

The boardwalk is a fishable room. The printed name of the boardwalk is "On a boardwalk beside the sea".
The description of the boardwalk is "This simple wooden pier juts into the sea. Pylons, evenly spaced, provide perches for cawing gulls. [boardwalk-details]On the horizon there is a smudge that might be the [link]island[as]x island[end link hilite]. Or a wave. It's hard to tell. You can't imagine how this could be any more boring. Or dreadful. Oh, and it has begun to rain.".

The player is in the boardwalk.

The catchable fish of the boardwalk are { mackerel, tomcod, herring, salmon }.
To say boardwalk-details:
	If the coil of rope is unnoticed:
		Say "Coils of [link]rope[as]x rope[end link hilite] lie about here and there[if the boardwalk-poles are in the boardwalk], and the[otherwise].[run paragraph on][end if]";
	If the boardwalk-poles are in the boardwalk:
		Say "[if the coil of rope is not unnoticed]The[end if] occasional discarded [link]fishing pole[as]x fishing pole[end link hilite] sways in the breeze. ".

The boardwalk can be henrico-conv-initiated. The boardwalk is not henrico-conv-initiated.
After looking when the player is in the boardwalk:
	If the boardwalk is not henrico-conv-initiated:
		Now the boardwalk is henrico-conv-initiated;
		Start a conversation with Henrico.
Akkoteaque is in the boardwalk.
The lighthouse is in the boardwalk.
Instead of examining Akkoteaque when the player is in the boardwalk:
	Say "That smudge on the horizon might be the island. The tall thing sticking out of it, with the spinning light on the top, might be the [link]lighthouse[as]x lighthouse[end link]. It might also not be, but you have to admit that, at this point, it probably is."
Understand "smudge" as Akkoteaque when the player is in the boardwalk.
Instead of examining  the lighthouse when the player is in the boardwalk:
	Say "That spinning light on the horizon is probably the Akkoteaque lighthouse. If it's not, something much stranger is going on.".
The backdrop-sea is in the boardwalk. 
Instead of examining the backdrop-sea when the player is in the boardwalk:
	Say "Gentle waves roll under the pier.".
	
The boardwalk-pylons are some scenery in the boardwalk with description "These simple wooden pylons hold up the pier. They are functional and very uninteresting.". Understand "pylon", "pylons" as the boardwalk-pylons.
The boardwalk-gulls are some scenery in the boardwalk with description "There aren't actually any gulls here. But the pylons would make great perches for them, if there were any.". Understand "gull", "gulls" as the boardwalk-gulls.
The boardwalk-poles are an action-list-suppressed thing in the boardwalk with description "Someone just left these fishing poles lying around. One of them looks to be in pretty good shape.[reveal the fishing pole][hide the boardwalk-poles]". Understand "poles", "fishing poles", "fishing", "pole" as the boardwalk-poles. The printed name of the boardwalk-poles is "fishing pole".
The fishing pole is in the boardwalk.
Instead of taking the boardwalk-poles:
	Reveal the fishing pole;
	Hide the boardwalk-poles;
	Try the player taking the fishing pole.
Instead of casting the boardwalk-poles:
	Reveal the fishing pole;
	Hide the boardwalk-poles;
	Try casting the fishing pole.
	
The outset-sign is a privately-named fixed in place thing in the boardwalk. The printed name is "garish sign". Understand "garish sign", "sign" as the outset-sign. The description is "This sign bears the word 'Akkoteaque' in large red letters (on a yellow background), and beneath it, in a much more reasonable font, 'Come see the world-famous [link]lighthouse[as]x lighthouse[end link]!'".

The coil of rope is a heavy container in the boardwalk. The coil of rope can be noticed or unnoticed. The coil of rope is unnoticed.
Before listing nondescript items of the boardwalk:
	If the coil of rope is unnoticed:
		Now the coil of rope is not marked for listing;
	Now the boardwalk-poles are not marked for listing;
	Continue the action.
The description of the coil of rope is "[if unnoticed]There are a few coils of rope tossed about the pier. One looks interesting... No, never mind. [end if]It's just a coil of rope.".
Understand "coil", "coils", "rope", "coils of rope", "coil of rope", "rope coil", "rope coils" as the coil of rope.
Rule for printing the name of the coil of rope while looking:
	Say "[link]coil of rope[as]x rope[end link]";
	If the coil of rope encloses nothing:
		omit contents in listing.
In the coil of rope is a mackerel.

After doing anything when the noun is the coil of rope:
	Now the coil of rope is noticed;
	Continue the action.
	
Instead of giving a fish (called the fish) to Shoo when Shoo is hungry:
	Say "The bird snatches the fish from your hand and almost takes some fingers too. Still looks just as angry, but at least it moves out of the way.";
	Now the fish is in the aquarium;
	Now Shoo is fed;
	Award 1 point with message "1 point for giving [a fish] to the pelican".

The ferry is a distant visible-at-a-distance fixed in place enterable container. It is in the boardwalk. The description is "The ferry is a squat little boat with little cliche [link]life savers[as]x life savers[end link] hanging on the sides. The inflatable kind, not the hard candy. It's painted in very patriotic colors complete with little stars." Understand "boat", "ferry boat", "farry" as the ferry. 
Instead of entering the ferry when Shoo is hungry:
	Say "[The shoo] won't move out of the way. It's standing right in the perfect spot to stop you and it's doing so in a very angry way. Your mother always tells you how angry you get when you're hungry. [if the player encloses the mackerel][link]Maybe you should feed the fish to the pelican[as]feed fish to pelican[end link][end if]."
A distant objects rule for the ferry when entering: rule succeeds.
The special actions of the ferry are { enter-enterable-container-action }.
After entering the ferry (this is the mark ferry near rule):
	Now the ferry is near;
	Continue the action;
After exiting when the ferry enclosed the player (this is the mark ferry distant rule):
	Now the ferry is distant;
	Continue the action.
After getting off the ferry (this is the second mark ferry distant rule):
	Now the ferry is distant;
	Continue the action.

The decor-life-savers are a privately-named part of the ferry with printed name "life savers". Understand "life savers", "savers", "life" as the decor-life-savers. The description of the decor-life-savers is "These are painted in red, white and blue stripes. They're about as pointlessly patriotic as the rest of the ferry.".

Instead of taking the decor-life-savers:
	Say "Those appear to be bolted to the side of the ferry. How would you get them off if you actually needed to use them?".

Rule for printing the name of the ferry while looking:
	Say "[link]ferry[as]x ferry[end link]";
	omit contents in listing.
	
Spider is in the ferry.
Elizabeth is in the ferry.
Shoo is in the boardwalk.
Death is in the boardwalk.
Henrico is in the boardwalk.

The sea is a fishable unsheltered room with printed name "On the sea". The description of the sea is "[if  the sea is choppy]Many short, shallow waves wash across the sea. The spray is a bit of a problem but at least your lunch isn't in any danger. A [link]cargo ship[as]x cargo ship[end link] sails past the island.[otherwise]Waves rush up and down. You can barely notice the chop over the crashing of the waves. Each thrust threatens to fling your lunch up your throat. You can only catch glimpses of the [link]cargo ship[as]x cargo ship[end link] through the waves.[end if]".  The sky is in the sea.
The catchable fish of the sea are { mackerel, tomcod, salmon, herring }.
The sea can be choppy or rough. The sea is choppy.
Akkoteaque is in the sea.
The lighthouse is in the sea.
The backdrop-sea is in the sea.
Instead of examining the backdrop-sea when the player is in the sea:
	If the current weather is Tempest:
		Say "Huge waves surge back and forth across the sea, throwing caps of white foam up the sides of the ferry.";
	Otherwise:
		Say "Gentle waves lap at the sides of the ferry.".
Instead of examining Akkoteaque when the player is in sea:
	Say "The island is growing larger every moment. It sort of looks like an upside down bucket with a few buildings poking out of the top. You can make out the outlines of the [link]lighthouse[as]x lighthouse[end link] easily enough. It is, after all, a lighthouse."
Instead of examining the lighthouse when the player is in sea:
	Say "The lighthouse is spinning at a steady pace. The rain does not exactly help, but you can make out a bit of a striped pattern from the picture.".

Instead of getting off the ferry when the ferry is in the sea:
	say "You contemplate leaping into the sea. You decide against it and stay where you are."
Instead of exiting when in the sea:
	say "You contemplate leaping into the sea. You decide against it and stay where you are."
	
The backdrop-cargo-ship is some privately-named distant visible-at-a-distance scenery in the sea. The printed name is "cargo ship". Understand "cargo", "ship", "cargo ship" as the backdrop-cargo-ship. The description of the backdrop-cargo-ship is "A large cargo ship plies across the sea between the ferry and the island. It's making good progress, though, and looks like it will be out of the way long before the ferry gets there.".

Chapter - Overworld

The overworld is a region.

Section - The Jetty

The jetty is a fishable holey room in the overworld. The printed name is "[if ghostly]On a small pier[otherwise]On a decrepit pier[end if]".  The description is "[if ghostly]This little wooden dock has definitely seen better days, but still seems to be going strong. It juts into the sea from the base of a cliff. Many [link]seagulls[as]x seagulls[end link hilite] wheel about in the sky above.[otherwise]You can't imagine how this rotting dock has not collapsed. It protrudes from the base of towering cliffs. [link]Seagulls[as]x seagulls[end link hilite] crowd the sky above you, very nearly blotting out the sun.[end if][If something is buried in the jetty] There is a patch of disturbed earth near the base of the cliff.[end if]".
The catchable fish of the jetty are { bluefish, flounder, rainbow smelt, cod, white perch, cusk }.
Instead of going inside when the player is in the jetty:
	Try entering the ferry.
The backdrop-sea is in the jetty.
Instead of examining the backdrop-sea when in the jetty:
	If the jetty is ghostly:
		Say "The sea shimmers in the sunlight. Small waves lap against the pier.";
	Otherwise:
		Say "Angry waves crash against the pier again and again.".
The ambient noise of the jetty is "[if ghostly]the cawing of seagulls[otherwise]a cacophony of gulls[end if]".
The gulls are plural-named scenery in the jetty. The description is "[if ghostly]Many gulls circle overhead hoping you might drop some scrap for them. One of them keeps returning to a narrow [link]cleft[as]x cleft[end link hilite] in the face of the cliff.[otherwise]Many gulls circle overhead, peering at you in hopes that they can steal some morsel. One of them returns again and again to it's lair in a narrow [link]cleft[as]x cleft[end link hilite] in the face of the cliff.[end if]".
Understand "seagulls" as the gulls.
The cleft is scenery in the jetty. The description is "There is a narrow cleft in the cliff just wide enough for a gull to scamper through. It looks like one of them has built a [link]nest[as]x nest[end link hilite] in there. It's not very high.".
Understand "cliffs", "cliff" as the cleft.
The nest is a distant scenery container in the jetty.  The description is "It seems to be an ordinary sort of bird nest. Ordinarily dirty.".
Instead of taking the nest:
	Say "You could take it, but then you'd need lots of hand sanitizer.".
	
Report dropping the ladder when the location of the player is the jetty: 
	Say "You lean the ladder against the face of the cliff."; 
	Stop the action.

A distant objects rule for the nest when the player is on the ladder: rule succeeds.
A distant objects rule for something enclosed by the nest when the player is on the ladder: rule succeeds.

The fire hydrant charm is in the nest.
Before examining the nest:
	Reveal the fire hydrant charm.

Upon becoming ghostly of the jetty:
	If Spider is restless:
		Now Spider is in the jetty.
	
Upon becoming lively of the jetty:
	Remove Spider from play.
	
The gas can is in the jetty.

The clam is buried in the jetty.

Report digging in the jetty:
	If the buried item found is not nothing:
		Say "You sink the shovel down between the planks and the stone face of the cliff. You manage to dig out [the buried item found].";
	Otherwise:
		Say "You sink the shovel down between the planks and the stone face of the cliff, but find nothing of interest.".

Section - The Narrow Stair

The narrow stair is a room in the overworld with printed name "Climbing a narrow stair".  The description is "[if ghostly]A narrow stair climbs through a seam in the rocks from the jetty to the top of the island cliffs. The steps are carved from the rock itself. [link]Vines[as]x vines[end link hilite] covered in tiny white flowers hide the rough rock walls.[otherwise]A narrow stair climbs through a crack in the rocks from the jetty to the top of the cliff. The steps are old and worn and marked by years of traffic. Dead [link]vines[as]x vines[end link hilite] cling to the walls on either side.[end if]".
The vines are some scenery in the narrow stair. The description is "[if ghostly]Vines are thick upon the rock walls. Thousands of tiny pink and white flowers cover the vines everywhere.[otherwise]These vines are dry and dead. There are bits of trash stuck in them.[end if]".
Understand "wall", "walls" as the vines.
The narrow stair is east of the jetty. 

Instead of pulling the vines:
	Say "You give the vines an experimental tug. They aren't anchored all that strongly.".
	
Instead of climbing the vines:
	Say "The vines pull away from the rock walls too easily. You'd never be able to climb up them.".
	
The decor-narrow-stairs are some privately-named scenery in the narrow stair with description "There are two giant rocks on either side. The stair goes right up the seam between them. The steps are fairly even and smooth, with just enough irregularity to retain that natural look. It's a very craggy island and it seems likely that this was a natural path from the water to the top of the cliff that's just been made easier to climb.".
Understand "steps", "stair", "stairs", "seam", "cliff", "rock" as the decor-narrow-stairs.

The decor-narrow-stairs-flowers are some privately-named scenery in the narrow stair with description "These tiny white flowers have four petals each. One petal is longer then the other three.".
Understand "flower", "flowers" as the decor-narrow-stairs-flowers when the narrow stair is ghostly.

Section - The Shack

The shack is a sheltered room with printed name "In a haphazard shack on the edge of a cliff". The description is "[shack-description]".
To say shack-description:
	If the shack is ghostly:
		Say "This shack is built right onto the side of the cliff, physics be damned. It's rather damp, likely due to it being suspended over the sea, but otherwise it's quite nice. There are some nautical themed [link]posters[as]x posters[end link hilite] on the walls and a little [link]window[as]x window[end link hilite] [if the shack-window is open]letting in a breeze.[otherwise]that looks out over the sea.[end if]";
	Otherwise:
		Say "This shack hangs precariously off the side of the cliff. I rattles with every step like it might fall down at any moment. It's dirty and dingy and everything is soaked. The walls are covered in tattered [link]posters[as]x posters[end link hilite] and the single dirty [link]window[as]x window[end link hilite] [if the shack-window is open]is about to fall out of it's frame[otherwise]lets in far too little light.[end if]".
	
The posters is some scenery in the shack. The description is "[if ghostly]Several posters decorate the walls. There is one showing some kind of [link]tall ship[as]x tall ship[end link hilite], another that appears to be a random assortment of [link]lighthouses[as]x lighthouses[end link hilite], and another that is clearly a [link]map[as]x map[end link hilite] of this very island.[otherwise]The tattered bits on the walls were probably interesting posters once.[end if]".
The shack-window is a fixed in place closed openable container in the shack. The printed name is "window". The description is "[window-details]".
To say window-details:
	If the window is ghostly:
		Say "The window looks out over the sea. Gentle waves roll by far below.";
	Otherwise:
		If the window is open:
			Say "The window looks out over the sea. Waves crash against rocks far below.";
		Otherwise:
			Say "The window is too dirty to see anything through it at all.".
Understand "window" as the shack-window.
The ambient noise of the shack is "[if lively]ominous creaking[end if]".
The shack is south of the narrow stair.

Instead of climbing the shack-window:
	Try entering the shack-window.
	
Instead of entering the shack-window:
	If the shack-window is closed:
		Say "The window isn't open.";
	Otherwise:
		Say "There's nothing on the other side but a long drop into the sea. Climbing through the window is probably not a great idea.".
		
Before listing nondescript items of the shack:
	Now the shack-window is not marked for listing;
	Continue the action.


The poster-ship is some scenery in the shack. Understand "ship", "tall", "tall ship" as the poster-ship. The description of the poster-ship is "This poster depicts a tall ship breaking apart on the rocks around a little island with a lighthouse on it. You can't tell if this is meant to be some specific ship because there isn't any sort of caption.".
The poster-lighthouses is some scenery in the shack. 
Understand "lighthouses", "lighthouse" as the poster-lighthouses when the location of the player is the shack.
The description of the poster-lighthouses is "This poster has photographs of various notable lighthouses on it, interspersed with pointless facts nobody could ever care about. The lighthouse on this island is absent.".
The poster-map is some scenery in the shack. Understand "map" as the poster-map. The description of the poster-map is "This poster appears to be a map of the island. The lighthouse is marked prominently on it. Attached to the lighthouse is the inn. To the west is the jetty where you landed on the island. To the south is a little chapel, and to the east, a little beach. Someone has drawn a little arrow pointing north on the beach.".
 

The ladder is in the shack.

The shack-bed is a privately-named bed in the shack with printed name "bed". The description is "[if ghostly]A basic and neatly-made bed. The bed spread is striped white and blue. Very nautical.[otherwise]The bed is rotted and rather disgusting. It's covered in mold too.[end if]".
Understand "bed" as the shack-bed.
Instead of taking the shack-bed:
	Say "That is far too heavy for you.".

The rusty table is a heavy portable supporter in the shack. The description is "[if ghostly]This cast iron table has intricate filigrees and is spotted all over in rust.[otherwise]This table was once made of metal. Now it is made of rust. Rust arranged in intricate spiraling filigrees.[end if]".

The ancient key is on the rusty table.
The sinker is on the rusty table.

Upon becoming lively of the shack:
	Hide the poster-map;
	Hide the poster-ship;
	Hide the poster-lighthouses.
	
Upon becoming ghostly of the shack:
	Reveal the poster-map;
	Reveal the poster-ship;
	Reveal the poster-lighthouses.

Section - The Square

The square is a room in the overworld with printed name "At a crossing of paths". The description is "[if ghostly]This is where the paths crossing the island meet. There's not much here besides some grass and some assorted shrubbery.[otherwise]This is where the paths crossing the island meet. There isn't much grass to speak of, just some dried up remnants and some dead shrubs.[end if] There is a [link]sign post[as]x sign post[end link hilite] pointing the way and a [link]tourist board[as]x tourist board[end link hilite] standing nearby.".
The square is east of the narrow stair.

The sign post is some scenery in the square. The description is "To the north is the inn and lighthouse. To the south is the chapel. The ferry is to the west, and the beach is to the east."
The tourist board is some scenery in the square. The description is "A rectangular sign covered in information about the island. It is all incredibly boring. For example, the lighthouse was built in 1867. Why would anyone care about that?".
Does the player mean quizzing someone about the tourist board: It is very unlikely.
Does the player mean implicit-quizzing the tourist board: It is very unlikely.

The ducks are in the square.

Upon becoming ghostly of the square:
	If Elizabeth is restless:
		Reveal Elizabeth;
	Hide Gerald.
	
Upon becoming lively of the square:
	Reveal Gerald;
	Hide Elizabeth.
	

Section - The Chapel exterior

The chapel exterior is an unsheltered room in the overworld with printed name "[if ghostly]Outside a tiny chapel[otherwise]Outside an old chapel[end if]".
The description of the chapel exterior is "[If ghostly]An old [link]chapel[as]x chapel[end link hilite] stands here at the southern edge of the island. It appears to be in good repair. Large [link]flagstones[as]x flagstones[end link hilite] set into the earth form a path leading to the front door of the chapel, lined with neatly cropped grass.[otherwise]An old [link]chapel[as]x chapel[end link hilite] stands here at the southern edge of the island. It hasn't been kept up very well. It needs a coat of paint, and some trim nailed back on, and to be demolished and entirely rebuilt. Cracked [link]flagstones[as]x flagstones[end link hilite] form a path leading to the front door.[end if] An old wrought iron fence blocks further travel to the south.".
The chapel exterior is south of the square.

The decor-chapel is a privately-named backdrop in the chapel exterior.
Understand "chapel" as the decor-chapel.
The description of the decor-chapel is "[If ghostly]The chapel is rather nice, actually, if you're into that sort of thing. It's very simple and very white, and the doors are the exact opposite.[otherwise]The chapel doesn't look like it's about to fall down. It looks like it already started and got stuck halfway to the ground.[end if]".

The cracked flagstones are some scenery in the chapel exterior with description "[if ghostly]This large, wide flagstones form a neat and orderly line, as if waiting to enter the chapel.[otherwise]The flagstones are all cracked and tilted at odd angles.[end if]".

The wrought iron fence is some scenery in the chapel exterior with description "The fence is made of wrought iron bars twisted into all sorts of spirals and twirls. Thick bushes have rendered it absolutely opaque, except the gate itself.".

The thick bushes are some scenery in the chapel exterior with description "Thick bushes block any view to the south. You can't see through the fence at all.".

Section - The Chapel Interior

The chapel interior is a sheltered room with printed name "[if ghostly]Amongst a set of quaint pews[otherwise]Under a rotting roof[end if]". 
The description of the chapel interior is "[If the chapel interior is ghostly]The simple roof is supported by wooden beams in the ceiling and walls, and everything has been whitewashed. Wooden [link]pews[as]x pews[end link hilite] sit in neat rows, with a central aisle that leads to the [link]altar[as]x altar[end link hilite]. A [link]crucifix[as]x crucifix[end link hilite] towers behind the altar.[otherwise]The patched roof is supported by wooden beams in the ceiling and walls. Everything is a sort of faded grey color. Worn old [link]pews[as]x pews[end link hilite] sit in disciplined rows, with a central aisle that leads to the dust-covered [link]altar[as]x altar[end link hilite]. A [link]smashed crucifix[as]x crucifix[end link hilite] lies in pieces behind the altar.[end if]".

The wooden beams are some scenery in the chapel interior with description "[if ghostly]They are freshly white washed and quite sturdy.[otherwise]They are a nasty grey color. With bits of green. They could collapse at any moment.[end if]".
The pews are some scenery in the chapel interior with description "[if ghostly]These are simple wooden benches. They are designed to be uncomfortable on purpose.[otherwise]These rotting wooden benches look like they'd fall apart if you tried to sit on them.[end if]".
The crucifix is some scenery in the chapel interior with description "[if ghostly]A tall crucifix stands behind the altar. Somehow, the redeemer manages to look serene while nailed to a chunk of wood.[otherwise]Bits and pieces of what was likely once a very nice porceline christ lie about the floor behind the altar.[end if]".

The ornate door is a door. It is west of the chapel exterior and east of the chapel interior.

The altar is a supporter in the chapel interior.
[The drawer is a locked openable scenery container in the chapel interior.

The dial is some scenery in the chapel interior. The description is "This small metal dial is marked with thirteen notches. Each notch is numbered, the first notch being 1 and the last, 13. It's currently set to [the set-value of the dial].".
The dial has a number called the set-value. The set-value of the dial is 7.

Setting it to a number is an action applying to one thing and one number.
Understand "set [something] to [number]" as setting it to a number.

Carry out setting something to a number (this is the default refusal to set things to numbers rule):
	Say "It doesn't seem to be possible to set [the noun] to a number.".
	
Instead of setting the dial to a number:
	Say "You turn the dial to [the number understood].";
]	

The communion wine is a fluid container on the altar. The description is "A bottle of cheap communion wine. [communion wine amount details]". The liquid of the communion wine is wine.
The communion wine is plural-named.
The communion wine has a number called the amount left. The amount left of the communion wine is 3.
To say communion wine amount details:
	If the amount left of the communion wine is 3:
		Say "The bottle is almost full.";
	Otherwise if the amount left of the communion wine is 2:
		Say "There's still plenty left in the bottle.";
	Otherwise if the amount left of the communion wine is 1:
		Say "It's almost gone.";
	Otherwise:
		Say "It's all gone.".

Section - Brisbane's Office

The chapel office is a sheltered room with printed name "In a messy office".
The chapel office is north of the chapel interior.
The description of the chapel office is "There are stacks of [link]papers[as]x papers[end link hilite] and books all about this office. A big oak [link]desk[as]x desk[end link hilite] fills up most of the space. Behind the desk a wooden [link]cross[as]x cross[end link hilite] hangs[if lively] askew[end if].".

The wooden cross is some scenery in the chapel office with description "It's a cross made of driftwood. There are flakes of blue and white paint still clinging to it.".
The stacks of papers and books is some scenery in the chapel office with description "Random stacks of papers sit here and there about the office, intermixed with books on by respected authors on the subjects of theology, paranormal activity, and Pierson's Pupeteers.".

Brisbane is in the chapel office.

The oak desk is a scenery supporter in the chapel office with description "This is a big flat utilitarian desk. It's built rather simply of oak.".
The chair is some scenery in the chapel office with description "A hard chair with a very straight back. It doesn't look very comfortable.".

The crystal glass is a fluid container on the oak desk. The description is "A crystal glass with some ice in it.". The liquid of the crystal glass is no-liquid.
The aspergillum is on the oak desk.
The amber bottle is a fluid container on the oak desk. The description is "A bottle of amber liquid. It has a picture of some kind of pirate captain on it. [amber bottle amount details]". The liquid of the amber bottle is amber liquid.
The amber bottle has a number called the amount left. The amount left of the amber bottle is 3.
To say amber bottle amount details:
	If the amount left of the amber bottle is 3:
		Say "The bottle is almost full.";
	Otherwise if the amount left of the amber bottle is 2:
		Say "There's still plenty left in the bottle.";
	Otherwise if the amount left of the amber bottle is 1:
		Say "It's almost gone.";
	Otherwise:
		Say "It's all gone.".

Show Brisbanes greeting is a truth-state that varies. Show Brisbanes greeting is false.

After going when the room gone to is the chapel office:
	If Brisbane is in the chapel office:
		Now show Brisbanes greeting is true;
	Continue the action.
		
Brisbane greeting is a truth-state that varies. Brisbane greeting is false.

Every turn when show Brisbanes greeting is true:
	If Brisbane is ghostly:
		Say "[The brisbane] looks up at you and says something, but all you hear is whispers.";
	Otherwise:
		If Brisbane greeting is true:
			Say "'Back again?' [the brisbane] asks.";
		Otherwise:
			Say "'It's Magdeline, right? [the brisbane] asks.";
			Now Brisbane greeting is true;
		Start a conversation with Brisbane;
	Now show Brisbanes greeting is false;
	Continue the action.
		
Before taking the crystal glass:
	If Brisbane is in the chapel office:
		If Brisbane is ghostly:
			Say "[The Brisbane] deftly swats your hand away, and whispers something you can't make out.";
		Otherwise:
			Say "[The Brisbane] deftly swats your hand away. 'That's not for children,' [the brisbane] says.";
		Stop the action;
	Continue the action.
	
Before taking the amber bottle:
	If Brisbane is in the chapel office:
		If Brisbane is ghostly:
			Say "[The Brisbane] deftly swats your hand away, and whispers something you can't make out.";
		Otherwise:
			Say "[The Brisbane] deftly swats your hand away. 'Bad idea, that. Look at what it's done to me,' [the brisbane] says.";
		Stop the action;
	Continue the action.
	
Every turn when the location of the player is the chapel office and the location of Brisbane is the chapel office:
	If a random chance of 1 in 2 succeeds:
		Say "[One of][The Brisbane] takes a sip from the crystal glass.[or][The Brisbane] looks at his glass and then thinks better of it.[or][The Brisbane] pours some liquid from the bottle into his glass.[purely at random]".
		

		

Section - The Graveyard

The graveyard is a fishable unsheltered room in the overworld with printed name "In an overgrown graveyard".
The description of the graveyard is "[if ghostly]A few [link]gravestones[as]x gravestones[end link hilite] covered in brambles stand about. Wildflowers rustle in the breeze. A row of hedges blocks off the north side of the graveyard, between you and the chapel. The south side is a cliff that drops into the sea. There's a picket fence to keep you from falling in.[otherwise]A few worn [link]gravestones[as]x gravestones[end link hilite] stand about amongst patches of dead wildflowers. Hedges block off the north side of the graveyard between you and the chapel. The south side is a cliff that drops into the sea, blocked by a rotting picket fence.[end if]".

The catchable fish of the graveyard are { striped bass, haddock, ocean pout, monkfish, mackerel, salmon, herring, tomcod }.

The iron gate is a locked lockable door. It is south of the chapel exterior and north of the graveyard.
The description of the iron gate is "It's a wrought iron gate. Through it you can see [if the location of the player is the chapel]an overgrown graveyard.[otherwise]a tiny chapel.[end if]".

The gravestones are some scenery in the graveyard. The description is "[one of]There is a small flush grave marker with the name 'Captain Theodore 'Spider' Boshkits'.[or]There is a rather traditional upright stone engraved with the name 'Elizabeth Thornwood'.[or]There is a cross with the name 'Franklin' on the horizontal part.[purely at random]".

The wildflowers are some scenery in the graveyard. The description is "[if ghostly]Daisies, or something. You don't know. You aren't a herbologist.[otherwise]They're all dead and crumbly.[end if]".

The picket fence is some scenery in the graveyard. The description is "[if ghostly]A very nice white picket fence.[otherwise]Bits of the fence have fallen into the sea.[end if]".

The decor-chapel is in the graveyard.

The graveyard-hedges are some privately-named scenery in the graveyard. The description is "[if ghostly]Thick hedges block any view to the north.[otherwise]Dead hedges block any view to the north.[end if]".
Understand "hedges" as the graveyard-hedges.

The bone key is a passkey. The bone key unlocks the iron gate.
The description of the bone key is "The handle of this key is shaped like a skull.".

The mausoleum is in the graveyard.

Section - The Beach

The beach is a fishable unsheltered room in the overworld with printed name "[if ghostly]On a small crescent of perfect sand[otherwise]On a dirty sliver of beach[end if]". The description is "[beach details]".
The catchable fish of the beach are { wolffish, redfish, cusk, brown trout, pollock, haddock }.
The beach is east of the square.
The waves are in the beach.
The lighthouse is in the beach.

Beach detail flag is a truth-state that varies. Beach detail flag is false.
To say beach details:
	If the beach is ghostly:
		Say "The beach is pure white, and the only thing marring it's surface is the occasional foot prints of a rather large pelican[if beach detail flag is true] and your own.[otherwise].[end if] [run paragraph on]";
	Otherwise:
		Say "The beach is dirty, but not in the way a thing made of sand is expected to be. There are great strands of [link]seaweed[as]x seaweed[end link hilite] lying about, and a decaying [link]jellyfish[as]x jellyfish[end link hilite]. [run paragraph on]";
	If the current weather is raining: 
		Say "[link]Waves[as]x waves[end link hilite] crash onto the shore, breaking in white foam.";
	Otherwise if the current weather is tempest:
		Say "[link]Waves[as]x waves[end link hilite] smash at the sand, throwing boughs of churning foam far up the beach.";
	Otherwise:
		Say "Gentle [link]waves[as]x waves[end link hilite] lap at the shore.";
	Now beach detail flag is true.
	
Instead of examining the waves when in the beach:
	If the current weather is raining:
		Say "The waves are rather large, but not too strong. They crash and roll in in steady rows.";
	Otherwise if the current weather is tempest:
		Say "Massive waves attack the shore. They are capped in white foam and tear violently at the sand.";
	Otherwise:
		Say "The waves slosh gently back and forth, racing high up the beach and down again, but barely leaving a mark.".
	
The foam is some scenery in the beach. The description is "At the leading edge of each wave is a [if the current weather is tempest]thick band[otherwise]narrow ribbob[end if] of frothy white foam. It stays about for a bit after the wave retreats, before it dissolves.".
	
The seaweed is some hidden scenery in the beach. The description is "Great long strands of slimey, disgusting seaweed lie across the beach where the waves have left it.".
Instead of taking the seaweed:
	Say "That would require touching the slimey, disgusting seaweed.".
	
The decaying jellyfish is some hidden scenery in the beach. The description is "This quivering mass of jellyfish looks an awful lot like a jello mould. Except that jello moulds don't have tentacles.".

Upon becoming lively of the beach:
	Reveal the seaweed;
	Reveal the decaying jellyfish.
	
Upon becoming ghostly of the beach:
	Hide the seaweed;
	Hide the decaying jellyfish.
	


Chapter - Caves

The caves is a region.

Section - The Ocean Cave

The ocean cave is a holey sheltered room in the caves with printed name "[if ghostly]In a cave filled with the sound of waves[otherwise]In a dank and noisy cavern[end if]".
The description of the ocean cave is "This cave is only accessible at low tide. The tide carries detritus in from the sea and piles it up here. It's left a big pile of rotting timber at the back of the chamber. A deep fissure splits the roof of this cavern into two halves.".
The ocean cave is north of the beach.
Index map with the ocean cave mapped east of the mine.
The ambient noise of the ocean cave is "the crashing of waves".

The pile of rotting timber is a scenery container in the ocean cave. The description of the pile of rotting timber is "These are some oddly familiar boards piled in a heap. It looks like this is where they washed up at.".

The lifesaver is a hidden thing in the rotting pile of timber. The description is "It's round, it floats, and it's striped red and white.". Understand "saver" as the lifesaver.

Before examining the pile of rotting timber:
	If the lifesaver is hidden, reveal the lifesaver;
	Continue the action.
	


Section - The rocky ledge

The rocky ledge is a fishable unsheltered room in the caves with printed name "On a little rock shelf hanging over the sea". The description of the rocky ledge is "[If ghostly]A shelf of rock protrudes from the base of the cliff. It is protected from the waves by some rocks jutting out of the sea. Vibrant [link]lichen[as]x lichen[end link] cling to every surface. The rock wall above you looks to be climbable.[otherwise]A precarious shelf of rock protrudes from the base of the cliffs. The rocks jutting from the sea before it do nothing to stop the waves. Every surface is covered in rotting [link]slime[as]x slime[end link].[end if]".
The catchable fish of the rocky ledge are { shad, cunner, longhorn sculpin, dogfish, tautog, skate }.
The lichen is some scenery in the rocky ledge. The description of the lichen is "[if ghostly]The lichen comes in every color imaginable, but mostly in green and shades of it.[otherwise]It's some kind of disgusting green slime. You won't be looking too close.[end if]".
Understand "slime" as the lichen when the rocky ledge is lively.
The rocky ledge is east of the ocean cave.

The rock wall is a staircase. It is above the rocky ledge and below the narrow ledge. The description is "The wall has hand-holds carved into it, which makes for a very easy climb.".

Section - The Mine

The excavation is a region.

An excavation lamp is a kind of thing. An excavation lamp is usually fixed in place. The description of an excavation lamp is usually "This is a fairly stereotypical industrial lighting device. That is, it's a light bulb in a metal cage.".

The mine is a holey sheltered room in the excavation with printed name "In a crude excavation". The description is "This was once a natural cave. It has since been expanded. Rough [link]timbers[as]x timbers[end link] have been wedged against the ceiling to keep it from caving in. [link]Roots[as]x roots[end link] hang from the ceiling like grasping tentacles. A deep [link]fissure[as]x fissure[end link] splits the floor into two stone slabs.".
The rough timbers are a backdrop in the mine. Understand "timber", "supports" as the rough timbers. The description is "They've been hacked into a general beamish shape and pounded together with big round nails. Whoever did is clearly not a carpenter.".
The roots are some scenery in the mine. Understand "root", "hanging roots" as the roots. The description is "Are these roots holding the ceiling together, or breaking it apart? Both, probably.".
Index map with the mine mapped east of the cellar.
In the mine is an excavation lamp.

[The sand fall is a staircase. It is above the ocean cave and below the mine. The description of the sand fall is "This slope of shifting sand almost looks like it's flowing. You know it's not, but the illusion is pretty strong.".
Instead of inserting the ladder into the sand fall:
	Say "The ladder isn't tall enough to reach the top.".
Instead of putting the ladder on the sand fall:
	Say "The ladder isn't tall enough to reach the top.".]
[The mine is above the ocean cave.]

The fissure is a backdrop with description "[fissure details]".
The fissure is in the ocean cave.
The fissure is in the mine.

To say fissure details:
	If the location of the player is the mine:
		If the ocean cave is visited:
			Say "A deep fissure splits the floor of this chamber. It is too narrow for you to fit anything through, but down below you can see the ocean cave.";
		Otherwise:
			Say "A deep fissure splits the floor of this chamber. It is too narrow for you to fit anything through, but down below you can see some sort of cave.";
	Otherwise:
		If the mine is visited:
			Say "A deep fissure splits the ceiling of this cave. Through it, you can see the mine.";
		Otherwise:
			Say "A deep fissure splits the ceiling of this cave. Through it, you can see another chamber.".
		


When play begins:
	Change the up exit of the ocean cave to nowhere.

Report digging in the mine:
	If the buried item found is not nothing:
		Say "There is a likely spot of soft earth over by the cave wall. You sink in your shovel, and after a few moments uncover [the buried item found].";
	Otherwise:
		Say "There is a likely spot of soft earth over by the cave wall. You sink in your shovel, but after several shovel fulls you still haven't found a thing.";
	Stop the action.

Upon becoming lively of the mine:
	Update the cellar mine connection.
	
Upon becoming ghostly of the mine:
	Update the cellar mine connection.
	
	
Section - The Narrow Tunnel

The narrow tunnel is a dark sheltered room in the excavation with printed name "Ducking through a narrow but heavily fortified tunnel". It is north of the mine.
In the narrow tunnel is an excavation lamp.
The description of the narrow tunnel is "The walls and ceiling are almost entirely hidden by the [link]timber[as]x timbers[end link] that is keeping the rock from crashing down on top of you. The tunnel is barely wide enough for you. Whoever dug it out must have walked sideways."
The rough timbers are in the narrow tunnel.

Section - The Colonnade Chamber

The colonnade chamber is a holey dark sheltered room in the excavation with printed name "In a hall of stalagmites". It is west of the narrow tunnel.
In the colonnade chamber is an excavation lamp.
The description of the colonnade chamber is "[link]Stalagmites[as]x stalagmites[end link] jut from the floor, stabbing upward at hanging [link]stalactites[as]x stalactites[end link].. or is it the other way around? Whichever way, the effect is of a grand hall lined with columns.[If the immense stone pile is in the colonnade chamber] An immense pile of [link]stone[as]x stone pile[end link] squats at the north end of the chamber. The pieces missing from the ceiling seem to indicate it is a recent collapse.[otherwise] Bits of exploded stone lay about the chamber.[end if][If something is buried in the colonnade chamber] There is a patch of disturbed earth in the corner.[end if]".
The immense stone pile is a scenery container in the colonnade chamber. The description is "A loose pile of jumbled stone.".
Understand "pile of stone" as the stone pile.
The stalagmites are some scenery in the colonnade chamber. The description is "These are definitely the ones that stick up. They look kind of like old melty candles.".
The stalactites are some scenery in the colonnade chamber. The description is "They're just hanging around.".

Section - The Treasure Chamber

The treasure chamber is a holey dark sheltered room in the excavation with printed name "In a tiny hollow with a sandy floor".
The description of the treasure chamber is "The scorch marks on the wall and the bits of broken stone lying about are probably from the blast that opened the way into this small chamber. The floor is sand, and you could swear you hear waves.[if something is buried in the treasure chamber] There is a patch of disturbed earth in the corner.[end if][if putting spider to rest is happening] A [link]shadow[as]x shadow[end link] passes across the narrow entrance to the chamber.[end if]".
In the treasure chamber is an excavation lamp.
The ancient chest is a closed locked container in the treasure chamber. The description is "This ancient chest is made from ancient board joined by ancient bolts and banded all about in ancient iron. The lock is also ancient. Presumably, so is the key.".
The gold doubloon is a thing in the ancient chest. The description is "On one side of this shiny gold coin is an eagle. On the other is some kind of triangle. Or a mountain. Something with that general triangular shape.".
The ancient key is a passkey. The ancient key unlocks the ancient chest.
The skeleton is a thing in the treasure chamber. The description is "The skeleton has his arms wrapped around the chest. He's holding on quite tight. Only bone and battered bits of cloth remain, yet he manages to stay in the position in which he presumably died.".
Instead of taking the skeleton:
	Say "You really don't like the idea of carrying around some guy's skeleton.".
Instead of taking the ancient chest:
	Say "In order to haul the chest out of here, you'll have to touch the skeleton. Which you are not going to do.".
Instead of touching the skeleton:
	Say "No. Way.".

Index map with the treasure chamber mapped north of the colonnade chamber.

The big hook is buried in the treasure chamber.

The shadow is some privately-named scenery in the treasure chamber. The description is "It looks like the shadow of a man standing in the chamber immediately to the south, but you can't see the man himself.".
Understand "shadow" as the shadow when Putting Spider to Rest is happening.

Section - Generator and Detonator puzzle

The gas can is a fluid container with liquid gasoline.

Instead of drinking the gas can:
	Say "You feel sick just from the fumes. Drinking that not going to happen.".

The generator is a heavy silent fluid container. 
The generator can be running or not running. The generator is not running.
The pull cord is a part of the generator.
Rule for printing the name of the generator while looking:
	Say "[link]generator[as]x generator[end link]";
	Omit contents in listing.
Every turn when the generator is running and the location of the generator is the location of the player:
	Say "The generator chugs away.".

Instead of pulling the pull cord:
	If the generator is running:
		Say "The generator is already running. No point in trying to start it again.";
	Otherwise:
		If the generator is empty:
			Say "You give that cord a good yank.. and nothing happens.";
		Otherwise:
			Say "You give that cord a good yank and the generator sputters to life.";
			Now the generator is running;
			Now every excavation lamp is lit.
	
Instead of pouring the generator into something:
	If the generator is empty:
		Say "It's already empty.";
	Otherwise:
		Say "There doesn't seem to be any way to get the fuel back out again.".
		
Instead of pulling the generator:
	Try pulling the pull cord instead.
Instead of using the generator:
	Try pulling the pull cord instead.
	
Instead of examining the generator:
	Say "It's an old beat up generator. There is a gas guage on the side.";
	If the generator is empty:
		Say "It reads empty.";
	Otherwise:
		Say "It reads full.";
	Say "There is also a pull cord on top, which you could [link]pull[as]pull cord[end link].";
		
Before printing the name of the generator:
	do nothing. 
	
The detonator is a heavy thing. The detonator can be depressed or primed. The detonator is primed. The description of the detonator is "This is a box with a handle sticking out of the top. Use the detonator and presumably something will explode.".
The slot is a fixed in place circuit on the detonator. The description is "There is a tiny label next to the slot. It says: 'fuse paddle type'.".
Rule for printing the name of the detonator while looking:
	Say "[link]detonator[as]x detonator[end link]";
	Omit contents in listing.
The detonator can be untouched, tested, or detonated. The detonator is untouched.
	
The stick of dynamite is a fixed in place thing in the immense stone pile. The description is "It's an orange stick. It's got a little tab on the end, probably where the detonator gets attached.".
Instead of taking the stick of dynamite:
	Say "It's stuck fast! You can't even wiggle it.".
	
The paddle fuse is a fuse. The paddle fuse completes the slot. The description of the paddle fuse is "The paddle fuse is two flat pieces of metal joined by a plastic handle.".

The wire is a plural-named thing. The wire can be attached-to-dynamite. The wire is not attached-to-dynamite. The wire can be attached-to-detonator. The wire is not attached-to-detonator.

To say fiddly wire details:
	If the wire is attached-to-dynamite:
		Say " It is attached at one end to a stick of dynamite";
		If the wire is attached-to-detonator:
			Say " and at the other to the detonator";
		Say ".";
	Otherwise if the wire is attached-to-detonator:
		Say " It is attached at one end to the detonator.".
		
The description of the wire is "A coil of thin wire. It's pretty ordinary wire, you could probably [command]attach[normal] it to things.[fiddly wire details]".

Instead of tying the wire to the stick of dynamite:
	If the wire is attached-to-dynamite:
		Say "The wire is already attached to the dynamite.";
	Otherwise:
		Now the wire is attached-to-dynamite;
		Say "You attach the wire to the dynamite.".
		
Instead of tying the wire to the detonator:
	If the wire is attached-to-detonator:
		Say "The wire is already attached to the detonator.";
	Otherwise:
		Now the wire is attached-to-detonator;
		Say "You attach the wire to the detonator.".
		
After going when the player encloses the wire (this is the wire can't stretch beyond the caves rule):
	If the room gone to is not in the excavation:
		If the wire is attached-to-dynamite:
			Say "The wire comes loose from the stick of dynamite.";
			Now the wire is not attached-to-dynamite;
		If the wire is attached-to-detonator:
			Say "The wire comes loose from the detonator.";
			Now the wire is not attached-to-detonator;
	Continue the action.		
	
Instead of reeling the wire:
	If the wire is not attached-to-dynamite and the wire is not attached-to-detonator:
		Say "It's already all wound up.";
	Otherwise:
		Say "You wind up the wire. Now it's not attached to anything.";
		Now the wire is not attached-to-dynamite;
		Now the wire is not attached-to-detonator.
		

Instead of using the detonator:
	Now the detonator is tested;
	If the detonator is depressed:
		Now the detonator is detonated;
		Say "You depress the detonator. Nothing happens.";
		Stop the action;
	If the wire is not attached-to-detonator:
		Say "You depress the detonator. Nothing happens. Probably because the detonator isn't attached to anything.";
		Stop the action;
	If the wire is not attached-to-dynamite:
		Say "You depress the detonator. Nothing happens. Probably because the other end of the wire isn't attached to anything.";
		Stop the action;
	If the slot is not complete:
		Say "You depress the detonator. Besides a little spark in the slot on the side of the detonator, nothing happens.";
		Stop the action;
	Say "You depress the detonator. There is a distant rumble and you feel the walls of the cave shake.";
	Change the north exit of the colonnade chamber to the treasure chamber;
	Change the south exit of the treasure chamber to the colonnade chamber;
	Hide the immense stone pile;
	Now the detonator is depressed;
	Now the detonator is detonated;
	Now the wire is not attached-to-dynamite;
	
The detonator is in the mine.
The paddle fuse is buried in the colonnade chamber.
The generator is in the mine.
The wire is in the colonnade chamber.

Chapter - Inn

The inn is a region.

Section - The Yard

The yard is an unsheltered room in the overworld with printed name "[If ghostly]On a lawn of green grass[otherwise]On a lawn of dry grass[end if]".
To say yard position details:
	If the immense birch encloses the player:
		Say "are high above";
	Otherwise:
		Say "stand on".
The description of the yard is "[if ghostly]You [yard position details] a manicured lawn of fine grass. The lighthouse towers above you. The inn is a two story house in a quaint Victorian style attached to the lighthouse. It appears to have been freshly painted in pastel pink and green.[otherwise]You [yard position details] a dead lawn. Patches of dirt show through the thin grass. The lighthouse looms above. The inn is a decaying two story structure covered in peeling pink and green paint.[end if]".
The decor-inn is some scenery in the yard with printed name "inn". The description is "[if ghostly]That house actually is quite nice. You weren't expecting it to look so.. well, wonderful.[otherwise]It would take more than a coat of paint to fix this place up. Half the siding has fallen off.[end if]".
Understand "inn", "house" as the decor-inn.

The yard is north of the square.

The Victorian porch is a scenery supporter in the yard. 
The description of the Victorian porch is "[if ghostly]A wooden porch of simple construction and complex ornamentation. The posts explode into a multitude of swirls and frills where they meet the roof, flowers, all carved of wood, flow from the banisters. Everything is painted in various pastels, predominately pink and blue.[otherwise]A porch of rotting timbers. Old flecks of paint cling to many surfaces. Some bits of broken scroll work hint at what once might have been a very lovely structure.[end if]".
The pastel blue door is a door with printed name "pastel blue door". The description of the pastel blue door is "[if ghostly]The door is covered in intricate carvings of birds and flowers, and painted pastel blue.[otherwise]The door is covered in peeling strips of blue paint and worm-eaten carvings of flowers.[end if]".
The pastel blue door is north of the yard and south of the sitting room.

The flower box is a fixed in place container on the Victorian porch. The description is "[if ghostly]This is a rough wood box for planting flowers in.[otherwise]This rotting wood box looks like it's about ready to fall apart.[end if]".
The flower box can be overflowing. The flower box is not overflowing.

Rule for writing a paragraph about the flower box when the flower box is overflowing:
	Say "Beautiful germaniums pile out of [the flower box] on the porch.".
	
Upon becoming lively of the flower box: 
	If the flower box is overflowing:
		Now the flower box is not overflowing;
		Now the germanium bulb is in the flower box.
		
Upon becoming ghostly of the flower box:
	If the flower box encloses the germanium bulb:
		Remove the germanium bulb from play;
		Now the flower box is overflowing.
		
		
The immense birch is a fixed in place enterable container in the yard. The description is "This is one of the few trees on the island[if the decor bark is not hidden]. It's rather gigantic and covered in peeling white bark[otherwise]. You've yanked a big chunk of bark right off it[end if].".
Understand "tree", "gigantic" as the immense birch.
Instead of putting something on the immense birch:
	Say "There doesn't seem to be any way to get [the the noun] to stay on the tree.".
Instead of inserting something into the immense birch:
	Try putting the noun on the immense birch.
Instead of going down when the player is enclosed by the immense birch:
	Try exiting.
Does the player mean taking the immense birch: It is very unlikely.
	
The decor-swing is a fixed in place privately-named thing in the immense birch. The printed name is "swing".	
The swing is an enterable scenery supporter in the yard. The description is "This ancient swing hangs from a branch high in the tree. You could take it for a [link]swing[end link].".

Implicit-swinging is an action applying to nothing.
Understand "swing" as implicit-swinging.

Carry out implicit-swinging:
	Say "You aren't on a swing.".
	
Instead of implicit-swinging when in the yard:
	If the player is not enclosed by the swing:
		Try the player entering the swing;
	If the player is enclosed by the swing:
		Say "You kick the swing back and forth. What a pleasant way to waste some time.";
		
Instead of swinging the swing when in the yard:
	Try implicit-swinging.
	
Instead of climbing the immense birch:
	Try entering the immense birch.
Report entering the immense birch:
	Say "You scramble up into the tree.".
	
The birch bark is a thing with description "A thin sheet of white bark.".
The birch bark is plural-named.
The decor bark is some privately-named scenery in the yard. The description is "Thin white bark. Very peely. You could pull it right off."
Understand "bark", "birch", "white" as the decor bark.
Does the player mean entering the decor bark: It is very unlikely.
Does the player mean taking the decor bark: It is very likely.

Peeling is an action applying to one thing.
Understand "peel [something]" as peeling.
Check peeling:
	Say "[The noun] would not be improved by peeling it, even if you found a way to.".
	
Instead of pulling the decor bark:
	Try taking the decor bark;
Instead of peeling the decor bark:
	Try taking the decor bark;
Instead of taking the decor bark:
	Now the player carries the birch bark;
	Hide the decor bark;
	Say "You peel off a large piece of bark.".
	
Section - The Sitting Room

The sitting room is a sheltered room in the inn. The printed name is "[If ghostly]In a quaint and tidy sitting room[otherwise]In a dusty sitting room[end if]".
The description of the sitting room is "[If ghostly]Pastel flowers crawl across the rugs, the furniture, and the wallpaper. There is a bookcase full of old books you have absolutely no desire to read, and various old knick knacks, and a very pervasive sense of 'old and boring'.[otherwise]Dust. Dust everywhere. On the rugs, on the furniture, on the peeling wallpaper. It covers the bookcase so thickly you can't read any of the titles.[end if]".

The stairs are a staircase. The description of the stairs is "[If ghostly]A narrow staircase connects the two floors of the inn. There's a sturdy hand rail in place for your safety.[otherwise]A sagging staircase connects the two floors of the inn. All the steps droop like they are about to collapse and there isn't even a hand rail.[end if]".
The stairs are above the sitting room and below the upstairs hallway.

The pastel flowers are some scenery in the sitting room with description "[if ghostly]The decoration is consistent, if nothing else. Everything is done up in pastel flowers. Absolutely everything. The furniture? Yes. The wallpaper? Absolutely. Even the pastel flowers have little pastel flowers on them, and so forth into infinity.[otherwise]You can just make out some faded flowers under all the dust. Unless those are fingerprints.[end if]".
Instead of taking the pastel flowers:
	Say "You'd need some sort of wallpaper-scraper to pull that off.[if the pastel flowers are lively] And a duster.[end if]".

The bookcase is some scenery in the sitting room. The description is "[if ghostly]The bookcase is filled with all the classics of literature. The sort of boring old books they make you read in school.[otherwise]There might be some books under all that dust. Maybe.[end if]".
Instead of taking the bookcase:
	Say "It's rather large, isn't it? Besides, it built into the wall.".
Instead of climbing the bookcase:
	Say "What would that accomplish? It doesn't lead anywhere.".
	
The dusty books are some scenery in the sitting room. The description is "[if ghostly]You know what sort of books. Books like the Adventures of Huckleberry Hound, and 2000 Leaques Under Minneapolis.[otherwise]Look kind of like big square chunks of dust at this point.[end if]".
Understand "book" as the books.
Instead of taking the books:
	Say "You really are not interested in reading that right now.".

The dust is some hidden scenery in the sitting room. The description is "The dust is grey, uniform, and everywhere. It's like a pervassive disease turning everything sickly and dull.".
Instead of taking the dust:
	Say "You run your finger through the dust. Now your finger is dusty. You wipe it on [the alabaster] and he doesn't notice.".

The furniture is some scenery in the sitting room. The description is "This sort of furniture is often called 'grandma furniture', because your grandmother owns it. [if ghostly]It is a bad name, since you distinctly remember that your aunt owned this sort of furniture too, and she was an old spinster.[otherwise]It is, unfortunately, very very dusty and thus not suitable for it's natural environment - estate sales.[end if]".
Instead of taking the furniture:
	Say "It would look fantastic in your apartment. Except you don't have an apartment. And also it would look horrible.".

The old knick knacks are some scenery in the sitting room. The description is "A bunch of generic knick knacks. You aren't really sure what any of them are, hence the term 'knick knacks'. Oh, that one might be a clock.. no, it is a cat.".
Instead of taking the old knick knacks:
	Say "You haven't got time to go and have a yard sale right now.".

The cat clock is some scenery in the sitting room. The description is "It's a cat and a clock! A cat clock! Fantastic. It seems to have stopped, though, and will probably show [the set time of the pocket watch] forever.".
Instead of taking the cat:
	Say "The cat clock absolutely does not scurry out of your reach. No. Because it is not a cat, it is a clock. Somehow, though, you completely fail to grab onto it.".


Alabaster is in the sitting room.

Upon becoming ghostly of the sitting room:
	Hide Alabaster;
	Hide the dust.
Upon becoming lively of the sitting room:
	Reveal Alabaster;
	Reveal the dust.
	

Section - The kitchen

The kitchen is a sheltered room in the inn. The printed name is "[If ghostly]In a breezy little kitchen[otherwise]In a dim and cramped kitchen[end if]".  The description is "[If ghostly]The windows of this kitchen are thrown open to let in the sun and breeze. It's a straight forward sort of kitchen with no frills, just a sink, cabinets, typical kitchen things.[otherwise]The walls of this little kitchen crowd in on you. Grimy windows don't let in enough light. There is a sink piled with dirty dishes, cabinets hanging open, and other typical kitchen things.[end if]".
The kitchen is north of the sitting room.
The ice box is a fixed in place closed openable container in the kitchen. The description is "[If ghostly]The ice box is pastel green. You can't imagine how old it must be. It's a little surprising that it even still works.[otherwise]The ice box is pastel green, except for the silver bits where all the paint is rubbed off. It doesn't appear to function any longer.[end if]".
The noise of the ice box is "[If ghostly]the hum of the ice box[end if]".
The round table is a supporter in the kitchen. The description is "[If ghostly]This is a round table covered with a white tablecloth.[otherwise]This is a round table. Most of the veneer appears to have pealed off.[end if]".
The refuse bin is a fixed in place container in the kitchen. The description is "[If ghostly]An uninteresting small plastic refuse bin.[otherwise]A small and disgusting plastic refuse bin. It smells awful.[end if]".
The torn page is in the refuse bin.


The loaf of bread is in the ice box.

The cart is in the kitchen.


Ilana is in the kitchen.
Upon becoming ghostly of the kitchen:
	Hide Ilana.
Upon becoming lively of the kitchen:
	Reveal Ilana.
	
Section - The Hedged Path

The hedged path is an unsheltered room in the overworld. The printed name is "[If ghostly]Between the hedges[otherwise]Between the dead hedges[end if]". The description is "Tall [link]hedges[as]x hedges[end link] confine you on either side of this path paved in worn stone.[if ghostly] They hedges are in full bloom.[otherwise] The hedges are dry and brown. They look like they could collapse at any moment.[end if]".
The hedged path is west of the yard.
The hedges are a scenery container in the hedged path. The description is "[if ghostly]These hedges are pretty thick and covered in small white flowers. They could use a bit of trimming.[otherwise]These hedges have likely been dead for quite a while.[end if]".

Section - The Garden

The garden is a holey unsheltered room in the overworld. The printed name is "[If ghostly]In a fantastic garden[otherwise]In a dead garden[end if]". The description is "[If ghostly]Your grandmother's garden is in full, glorious bloom. Flowering vines arch over head on wicker work canopies. A [interest]balcony[normal] overlooks the garden.[otherwise]Nobody has tended this garden in a long while. Some of the perennials appear to have sprouted, but they didn't get very tall before they wilted and died. Dead vines hang from wicker work canopies overhead. A [interest]balcony[normal] overlooks the garden.[end if][If something is buried in the garden] There is a patch of disturbed earth in the flower bed.[end if]".
The ambient noise of the garden is "[if ghostly]the chirping of birds[end if]".
The garden is north of the hedged path.

The glass table is a supporter in the garden. The description is "[If ghostly]The glass table is etched with patterns of leaves and blooming flowers.[otherwise]The table is covered in years of dirt and grime.[end if]".
The raster graphics manual is on the glass table.

The storm door is a door. It is east of the garden and west of the kitchen. The description of the storm door is "[If ghostly]It's a white storm door with a screen in the top half.[otherwise]The screen has gone missing from this door. Instead, someone has taped a black trash bag over it.[end if]".


The garden decor ladder is a hidden privately-named staircase with printed name "ladder".  The garden decor ladder is above the garden and below the balcony room.
The garden decor balcony is a privately-named backdrop in the garden. The description is "There is a balcony overlooking the garden. It's not that high."
Understand "balcony" as the garden decor balcony.

Instead of climbing the ladder when the player is in the garden:
	If the player encloses the ladder:
		Say "(first dropping the ladder)";
		Try dropping the ladder;
	Try entering the garden decor ladder;
Instead of climbing the ladder when the player is in balcony room:
	Try entering the garden decor ladder;

Report dropping the ladder when the player is in the garden:
	Say "You lean the ladder up against the wall. It reaches to the balcony.";
	Reveal the garden decor ladder;
	Stop the action.
	
After taking the ladder when the player is in the garden:
	Hide the garden decor ladder;
	Continue the action.
	
The germanium bulb is a thing with description "It's small, round, and dirty, and if you planted it, germaniums would grow from it.".

Report digging in the garden:
	Say "There's a fantastic digging spot under the germaniums. You sink in your shovel and find [the buried item found].";
	Stop the action.

The germanium bulb is buried in the garden.
The shovel is in the garden.
The worm is buried in the garden.

Every turn (This is the prevent pathfinding from using temporary garden ladder rule):
	If the ladder is enclosed by the garden and the ladder is not enclosed by the player:
		If the player is enclosed by the garden or the player is enclosed by the balcony room:
			Reveal the garden decor ladder;
		Otherwise:
			Hide the garden decor ladder.
		

Section - The Upstairs Hallway

The upstairs hallway is a sheltered room in the inn. The printed name is "In a narrow hallway".
The description of the upstairs hallway is "[if ghostly]This short, neat hall has absolutely nothing of interest in it. It's too narrow to stick anything in it. Even pictures on the walls would just get in the way.[otherwise]The only thing in this hallway is some doors and spiderwebs. It's a hallway. It's really only there to pass through.[end if]".

The spider webs are some hidden scenery in the upstairs hallway. The description is "Some old dusty spider webs cling to the corners up by the ceiling. Even the spiders have moved on.".
Understand "spiderwebs" as the spider webs.

Upon becoming ghostly of the upstairs hallway:
	Hide the spider webs.
	
Upon becoming lively of the upstairs hallway:
	Reveal the spider webs.

The ambient noise of the upstairs hallway is "[if the upstairs hallway is lively and Catherine is asleep]loud snoring[end if]".

Every turn when the location of the player is the upstairs hallway:
	If the upstairs hallway is lively:
		If Catherine is asleep:
			Say "A snore like a buzz saw comes from the room to the north.";
		Otherwise if Ilana encloses the apple key:
			Say "'[not Ilana]!' yells someone in the room to the north.".
		
Instead of hitting the tree door with the wrench:
	Say "You bang on [the tree door] with [the wrench].";
	If Catherine is asleep:
		If the upstairs hallway is lively:
			Say "The snoring stops abruptly.";
			Now Catherine is awake;
			Now Catherine is familiar.
			
Instead of hitting the tree door with the prybar:
	Say "You bang on [the tree door] with [the prybar].";
	If Catherine is asleep:
		If the upstairs hallway is lively:
			Say "The snoring stops abruptly. You really didn't think the prybar was heavy enough, but it sure did the trick.";
			Now Catherine is awake;
			Now Catherine is familiar.
			
Instead of hitting the tree door with something:
	Say "You bang on [the tree door] with [the second noun].";
	If Catherine is asleep:
		If the upstairs hallway is lively:
			Say "That doesn't seem to have done the trick. You need something really big and heavy.".
			
Instead of hitting the tree door:
	Say "You bang on [the tree door] with your knuckles.";
	If Catherine is asleep:
		If the upstairs hallway is lively:
			Say "That doesn't seem to have done the trick. You need something really big and heavy.".
	
	
Section - The Balcony Room

The balcony room is a sheltered room in the inn. The printed name is "In a room with a large balcony". The description is "[if ghostly]The large balcony in this room lets in a great deal of light. The room is decorated in a sort of post-colonial style, which means that there's a lot of linen and bare wood and knickknacks like the sort you'd pay too much for at an antique store.[otherwise]The large balcony in this room lets in a great deal of light, which has not been kind to the decorations. Everything is faded, wether from it's coating of dust or from sitting out in the sunlight for too long. The room has that sense about it that a room gets when nobody has used it in a very long time.[end if][if the garden decor ladder is not hidden] There is a ladder leaning up against the balcony.[end if]";
The balcony room door is a locked lockable door. It is east of the balcony room and west of the upstairs hallway.

After deciding the scope of the player when the player is in the balcony room:
	If the garden decor ladder is not hidden:
		Place the garden decor ladder in scope;
	Place the sky in scope;
	
Understand "ladder" as the garden decor ladder when (the player is in the balcony room) and (the garden decor ladder is not hidden).

Instead of examining the garden decor ladder when the player is in the balcony room:
	Say "The ladder leads down into the garden. You don't think you'd be able to pull it up.".
	
Instead of taking the garden decor ladder when the player is in the balcony room:
	Say "You aren't going to be able to pull the ladder up.".

The linens are some scenery in the balcony room with description "[if ghostly]Gaily colored linens cover every flat surface. The bed; the dresser; bits of the floor.[otherwise]Faded lines cover every flat surface. They are so old and worn that holes are appearing in them.[end if]".
Understand "linen" as the linens.

The br-bed is a privately-named bed in the balcony room.
Understand "bed" as the br-bed.
The printed name of the br-bed is "bed".
The description of the br-bed is "[if ghostly]A big soft bed, covered in gaily colored linens.[otherwise]The bed is sagging in the middle. It doesn't look that comfortable.[end if]";

The scrawl is a hidden thing in the balcony room. The description is "[cipher-waiting]".
Upon becoming lively of the balcony room:
	Reveal the scrawl.
Upon becoming ghostly of the balcony room:
	Hide the scrawl.
Instead of taking the scrawl:
	Say "It's just some stuff written on the wall. How are you going to take it?".

The room key is a passkey. It unlocks the balcony room door.
The description of the room key is "This is a small, rather ordinary looking key. The only remarkable thing about it is it's total unremarkableness.".

The dresser is a supporter in the balcony room. The room key is on the dresser.
The description of the dresser is "[If ghostly]The dresser is a squat, utilitarian affair hiding beneath a bright linen drapery.[otherwise]The dresser is not at all hidden by the worn linen draped haphazardly across it's surface.[end if]".
The vintage photograph is a thing on the dresser. The description is "It's a worn old photograph of a girl who looks just like you, the poor thing.".
The thimble charm is on the dresser.

A ladder accessibility rule for the balcony room:
	If the balcony room door is locked and the room key is enclosed by the balcony room:
		Rule succeeds;
	Rule fails.
	
The balcony room is ladder-accessible.
The ladder accessibility point of the balcony room is the garden.

Section - The Cellar

The cellar is a sheltered room in the inn with printed name "[if ghostly]In a tidy cellar[otherwise]In a dark and crowded cellar[end if]". The description of the cellar is "[if ghostly]Canned goods are stacked neatly on shelves throughout the cellar. This is most definitely a cellar, not a basement. The distinction is subtle, but mostly involves whether or not it's full of useless knick knacks. Someone has written a message on the east wall.[otherwise]A few empty cans lay scattered around the floor. It's very dirty. Not just a nobody has swept up in a while kind of dirt, but as if someone has actually been actively hauling dirt down here and dumping it.[end if]".
The cans are some scenery in the cellar. Understand "can", "empty cans" as the cans. The description of the cans is "[if ghostly]The cellar is very well stocked. There are cans of every imaginable food-stuff. Beets, Artichoke hearts, Garbanzo beans. If you can imagine it and it is disgusting, it's here.[otherwise]There's a few empty cans scattered about in the dirt.[end if]".
Instead of taking the cans:
	If the cans are ghostly:
		Say "You really don't need a can of [one of]pickled herring[or]dehydrated goat's milk[or]expired pumpkin pie filling[or]potted pig snouts[at random] right now.";
	Otherwise:
		Say "You won't get much use out of a dented old can.".
The cellar wall is scenery in the cellar. Understand "east", "east wall", "message" as the cellar wall. The description of the cellar wall is "[if ghostly]'dig here', the message says. And there is a big circle drawn under it.[otherwise]There is a giant hole in the wall. Maybe that's where all the dirt came from?[end if]".
The cellar stair is a staircase. It is above the cellar and below the kitchen. The description of the cellar stair is "[if ghostly]It's a perfectly ordinary staircase. You are interested in such boring things.[otherwise]It looks a little rickety. Would be kind of a shame if it fell down.[end if]".

Instead of digging in the cellar:
	If the cellar is lively, say "There's already a big hole in the wall.";
	Otherwise say "You knock the shovel ineffectively against the cinder block wall. This might take a while.".

To update the cellar mine connection:
	[Say "{Updating cellar->mine connections}.";]
	If the mine is lively or the cellar is lively:
		Change the east exit of the cellar to the mine;
		Change the west exit of the mine to the cellar;
	Otherwise:
		Change the east exit of the cellar to nothing;
		Change the west exit of the mine to nothing;

Upon becoming lively of the cellar:
	Update the cellar mine connection.
Upon becoming ghostly of the cellar:
	Update the cellar mine connection.
	
Section - Bay Room

The bay room is a sheltered room in the inn with printed name "In a room defined by it's giant window". The description of the bay room is "[if ghostly]This room is so bright and cheery, with it's large [interest]window[normal] letting the sunlight pour right in. The walls are blue and white stripes. It could be tacky, but here it works, as the entire room is done up in a nautical theme.[otherwise]No amount of sunlight pouring through that [interest]window[normal] could make up for this room's dingy decor. The walls are done up in tacky blue and white stripes.[end if]".

The tree door is a locked lockable door. The tree door is north of the upstairs hallway and south of the bay room. The description of the tree door is "[if the location of the player is ghostly]A carving of a tree spreads it's branches across this door. Fat apples hang amongst it's leaves.[otherwise]The door is bare, plain white.[end if]".
The printed name of the tree door is "[if the location of the player is ghostly]tree door[otherwise]plain white door[end if]".
Understand "plain door", "white door", "plain", "white", "plain white door", "plain white" as the tree door when the location of the player is lively.


The apple key is a passkey. The apple key unlocks the tree door. The description is "This little house key has an apple on the bow.".

The bay window is some scenery in the bay room. The description is "An enormous bay window dominates the wall of the room. Through it, you can see the sea.[if lively] It's a shame about the overcast sky.[end if]".

After deciding the scope of the player when in the bay room:
	Place the sky in scope;
	Place the backdrop-sea in scope;
	
The old bed is a bed in the bay room. The description is "[if ghostly]This old four-poster is covered in fluffy blankets.[otherwise]This old four-poster is sagging in the middle.[paragraph break]On [the old bed] is [Catherine].[end if]".
Instead of taking the old bed:
	Say "That's way too heavy for you.".
	
Upon becoming lively of the bay room:
	Reveal Catherine;
	
Upon becoming ghostly of the bay room:
	Hide Catherine;
	
Catherine is in the bay room.
	
The wardrobe is a closed openable container in the bay room. The description is "This curvy wardrobe would not look out of place on an old tall ship. It's got a certain nautical flair.[if lively] Unfortunately, all the veneer is peeling off.[end if]".
The handful of letters is a thing in the wardrobe. The description is "This is a handful of unopened letters. Each has the same return address, the Lighthouse Inn, Akkoteaque. Each is addressed to.. you? but at different addresses. You recognize most of these places as cities you lived in while your father's work dragged you around the country. Each letter was returned for some reason or another.".

After examining the handful of letters:
	If the player can see Catherine:
		If Catherine is not introduced:
			Say "You take another look at [the Catherine]. She does look familiar, you just didn't expect your grandmother to be so old.";
			Introduce Catherine;
			Expand the Catherine list;
			
The nightstand is a portable heavy supporter in the bay room with description "[if ghostly]This small square nightstand is painted in pastel blue.[otherwise]This small square nightstand is covered in flaking blue paint.[end if]".
The lure is on the nightstand.
The slipper charm is on the nightstand.


			
				
			
			
Chapter - The Lighthouse

The functional lighthouse is a region.

Section - The Machinery Room

The machinery room is a sheltered room in the functional lighthouse with printed name "At the bottom of the lighthouse". The description of the machinery room is "[if ghostly]You are in a cold, rather poorly lighted room with bare brick walls. The ceiling is way up above you. A staircase, guarded by a gate, spirals around the exterior of the lighthouse towards it's top far above. There is some thick electrical cabling running from the east wall to the elevator.[otherwise]You are in a cold, poorly lighted room with damp brick walls. Puddles stand about on the floor. A rickety looking staircase, blocked off by a gate, spirals around the exterior of the lighthouse towards it's top far above. There is some decayed electrical cabling running from the east wall to the elevator.[end if]".
The elevator is in the machinery room.
The grated stair is a locked lockable closed openable staircase. It is above the machinery room and below the lighthouse apex. The description of the grated stair is "The staircase is blocked by a locked gate.[if lively] It's for the best. It doesn't look safe anyway.[end if]".
The oak door is a door. The oak door is east of the sitting room and west of the machinery room. The description of the oak door is "A thick oak door.[If the location of the player is the sitting room] It says 'STAFF ONLY' on it.[otherwise if lively] There is a streaked hand print right in the middle of it. Is that mud? Let's assume it's just mud.[end if]".
The metal rack is a supporter in the machinery room. The description is "A plain metal rack.".
The prybar is on the metal rack.

Franklin is in the machinery room.

Upon becoming lively of the machinery room:
	Hide Franklin;
	
Upon becoming ghostly of the machinery room:
	If Franklin is not at peace, reveal Franklin;
	
Section - The Lighthouse Apex

The high-sky is a region.

The lighthouse apex is a sheltered room in the high-sky with printed name "At the apex of the lighthouse". The description is "[if ghostly]You are at the very top of the lighthouse. Shining glass [link]windows[as]x windows[end link] surround you on all sides. The floor and beams between the glass panes are all polished metal. There is a giant device in the center of the chamber, a sort of socket for giant light bulbs.[otherwise]You are at the very top of the lighthouse. Dirty glass [link]windows[as]x windows[end link] surround you on all sides. The floor is spotted in rust and grime. There is a giant device in the center of the chamber, a sort of socket for giant light bulbs.[end if]".
Index map with the lighthouse apex mapped east of the upstairs hallway.
The sky is in the lighthouse apex.

The apex windows are some privately-named scenery in the lighthouse apex.
Understand "windows", "glass", "glass windows", "shining glass", "shining windows", "shining glass windows", "dirty", "dirty glass", "dirty windows", "dirty glass windows" as the apex windows.
The description of the apex windows are "[if ghostly]Through the shining glass windows you can see a narrow metal balcony, and then nothing but sky.[otherwise]Through the dirty windows you can just barely make out a narrow metal balcony.[end if]".

The apex window balcony is some privately-named scenery in the lighthouse apex. The description is "This narrow metal balcony is on the outside of the lighthouse.".
Understand "balcony" as the apex window balcony.

Section - The Lighthouse Balcony

The lighthouse balcony is an unsheltered room in the high-sky with printed name "On the balcony". The description is "[If ghostly]A narrow metal balcony encircles the top of the lighthouse. A thin metal railing separates you from a very long drop. On the opposite side, shining glass [link]windows[as]x windows[end link] look into the lighthouse apex. The sea doesn't seem to reach all way up here, so at least it's dry.[otherwise]A narrow metal balcony encircles the top of the lighthouse. It's pitted with rust and filth. A rickety railing is all that separates you from a very long drop. On the opposite side, dirty glass [link]windows[as]x windows[end link] look into the lighthouse apex. Everything is damp and slippery.[end if]".
The surf is in the lighthouse balcony.
The apex hatch is a closed openable door with description "[if ghostly]This small door resembles a hatch on a ship.[otherwise]This small hatch is little more than a big chunk of rust.[end if]". 
The apex hatch is east of the lighthouse apex and west of the lighthouse balcony.

The balcony windows are some privately-named scenery in the lighthouse balcony.
Understand "windows", "glass", "glass windows", "shining glass", "shining windows", "shining glass windows", "dirty", "dirty glass", "dirty windows", "dirty glass windows" as the balcony windows.
The description of the balcony windows are "[if ghostly]Through the shining glass windows you can see the lamp and control room.[otherwise]Through the dirty windows you can just barely make out the lamp and control room.[end if]".

	
Instead of examining the lighthouse when in the lighthouse balcony:
	Say "You're standing on it. From up here, you can see details you can't see from the ground, like the [interest]lightning rod[normal] on top.".

The lighthouse balcony decor ladder is a hidden privately-named staircase with printed name "ladder".  The lighthouse balcony decor ladder is above the lighthouse balcony and below the lighthouse roof.
The decor-lightning-rod is a privately-named backdrop in the lighthouse balcony. The description is "There is a lightning rod jutting from the top of the lighthouse. The roof is not that high.".
Understand "rod", "lightning rod" as the decor-lightning-rod.

Instead of climbing the ladder when the player is in the lighthouse balcony:
	If the player encloses the ladder:
		Try dropping the ladder;
	Try entering the lighthouse balcony decor ladder;
Instead of climbing the ladder when the player is in the lighthouse roof:
	Try entering the lighthouse balcony decor ladder;

Report dropping the ladder when the player is in the lighthouse balcony:
	Say "You lean the ladder up against the wall. It reaches to the lighthouse roof.";
	Reveal the lighthouse balcony decor ladder.
	
After taking the ladder when the player is in the lighthouse balcony:
	Hide the lighthouse balcony decor ladder;
	Continue the action.
	
Section - The Lighthouse Roof
	
The lighthouse roof is an unsheltered room in the high-sky with printed name "On the very top of the lighthouse". The description is "You are at the very top of the lighthouse. You can see almost the entire [link]island[as]x island[end link] from here. A lightning rod stabs at the sky from the center of the lighthouse. Some wires start at it's base and drape across the roof. A little [link]nest[as]x nest[end link] is tucked in at the bottom of the lightning rod.".

The lighthouse roof is ladder-accessible.
The ladder accessibility point of the lighthouse roof is the lighthouse balcony.

The sky is in the lighthouse roof.
Akkoteaque is in the lighthouse roof.
Instead of examining Akkoteaque when in the lighthouse roof:
	Say "The whole island is laid out below you like a map.".
The lightning rod is some scenery in the lighthouse roof. The description is "The lightning rod juts up from the top of the lighthouse. Some [link]wires[as]x wires[end link] connected to it's base trail away across the roof.".
The wires are some scenery in the lighthouse roof. The description is "Upon closer examination, you discover that the wires have been cut and spliced back together.".

The eagles nest is some scenery in the lighthouse roof. The description is "This pile of bramble and trash is apparently an eagle's nest. You can tell because there is an eaglet in it.[first time][reveal the lighthouse charm] There is also a little charm. You didn't see that before.[only]".
Instead of taking the eagles nest:
	Say "The eagle who built it is probably going to be back any moment. Don't want to make her mad.".
The eaglet is a person in the eagles nest with printed name "eaglet". The description is "A tiny and mostly bald eagle chick. It's still in that stage where baby birds look like tiny aliens.".
Instead of taking the eaglet:
	Say "The eaglet probably wouldn't mind being carried about, but the eagle will have some choice things to say about it.".
Response of the eaglet when asked about something:
	Say "What noise do eaglet's make? It's just sort of a high pitched squeak. 'Squeak', it squeaks.".
The lighthouse charm is in the eagles nest.

Section - The Utility Room

The utility room is a sheltered room in the functional lighthouse  with printed name "[If ghostly]In a dusty utility closet[otherwise]In a dank utility closet[end if]".  The description of the utility room is "You are in a small room with a low ceiling. Various pipes and things pass through the room, making it even more claustrophobic. There is a general mustiness about[first time], which you have suddenly realized is a contraction of 'moist' and 'dusty'[only].[if lively] Nobody has been in here in a long time. You can tell, by the way you're leaving footprints in the dust.[end if]".
The utility door is a door. It is north of the machinery room and south of the utility room. The description of the utility door is "It's a rather boring wood door. Someone has, in a fit of imagination, stenciled 'utility' on it.[if lively] One of the hinges has broken and the door hangs at an odd angle.[end if]".
The workbench is a supporter in the utility room. The description of the workbench is "[If ghostly]A wooden bench. The top is scored by many years of use.[otherwise]Termites have been at this workbench. If it wasn't attached to the wall it probably wouldn't remain standing.[end if]" 

The green fuse is on the workbench.
The red fuse is on the workbench.
The wrench is on the workbench.

The small hook is a supporter in the utility room with carrying capacity 1. The description of the small hook is "It's a hook mounted on the wall. Presumably for hanging things on. The little sign above it that says 'keys' suggests the hook may be used for hanging keys.".

Check putting a thing (called the item) on the small hook:
	If the item is a passkey:
		Continue the action;
	If the item is a keychain:
		Continue the action;
	Say "There's not really any way to get that to stay on.";
	Stop the action.
	
The brass ring is a keychain with description "It's one of those nasty little key rings that coil back on themselves. Good luck getting a key on it without tearing off your nail.".
The iron key is on the brass ring.
The brass ring is on the small hook.

Instead of wearing the brass ring:
	Say "It's not that kind of ring.".
	
Section - The Narrow Ledge

The narrow ledge is an unsheltered room in the functional lighthouse  with printed name "On a narrow ledge". The description is "[if ghostly]This narrow ledge circles around the lighthouse. There is a sheer drop on the eastern side into the [link]surf[as]x surf[end link]. The lighthouse looms over you on the opposite side. The ledge is mostly concrete with big fat rocks stuck in it.[otherwise]This slick ledge circles around the lighthouse. Here and there puddles sit on the stones. The ledge is mostly concrete with big fat [link]rocks[as]x rocks[end link] stuck in it. The surf is pounding on the eastern side of the ledge, far below, and the lighthouse looms over you on the opposite side.[end link]".
The big fat rocks are some scenery in the narrow ledge with description "The ledge, and, it appears, the entire base of the lighthouse, are built out of concrete with fist sized river rocks embedded in the surface. They're smooth and come in a variety of colors ranging from brown to lighter brown.[if lively] The ones underfoot are pretty slick.[end if]".
The surf below is in the narrow ledge. 
The lighthouse is in the narrow ledge.
The backdrop-sea is in the narrow ledge.
Instead of examining the lighthouse while in the narrow ledge:
	Say "The lighthouse looms beside you. You can't get a good look at the top from here.".
Narrow-Ledge-Shoo-State is a number that varies. Narrow-Ledge-Shoo-State is 0.

Instead of hitting shoo when (the player is in the narrow ledge) and (Narrow-Ledge-Shoo-State is 0):
	Say "You pull back your hand and give that bird a nice smack. [The Shoo] has nowhere to go on such a narrow ledge and barely has a chance to squack before you connect. [The Shoo] flies off in a mass of idignant feathers.";
	Now Shoo is on the boardwalk;
	Now Narrow-Ledge-Shoo-State is 1.
	
Instead of hitting shoo with something when (the player is in the narrow ledge) and (Narrow-Ledge-Shoo-State is 0):
	Try hitting shoo.
	
Instead of going south when (the player is in the narrow ledge) and (Narrow-Ledge-Shoo-State is 0):
	Say "[The Shoo] is blocking your path.".
	
After giving a fish to shoo when (the player is in the narrow ledge) and (Narrow-Ledge-Shoo-State is 0):
	Say "She seemed to like the fish, but she doesn't seem inclined to get out of your way.".
	
The hatch door is a door. It is east of the utility room and west of the narrow ledge. The description of the hatch door is "This is the sort of door you might find on a ship. It's a rectangular hatch with rounded corners. It's got a big wheel on it.".
The hatch wheel is part of the hatch door. The description of the hatch wheel is "It's a big metal wheel. Looks pretty rusted.".

Instead of turning the hatch wheel:
	Say "It's stuck fast.".
	
Section - The Electrical Alcove
	
The electrical alcove is an unsheltered room in the functional lighthouse  with printed name "An alcove at the end of the ledge". The description is "The ledge ends at a little alcove cut into the side of the [interest]lighthouse[normal]. To the south, you can see the beach. To the east, nothing but the sea all the way to the horizon.[if lively] The lighthouse is covered in grime and filth. Lichen crawls over the rocks under your feet. Watch your step.".
The electrical alcove is south of the narrow ledge.
The surf below is in the electrical alcove.
The lighthouse is in the electrical alcove.
The backdrop-sea is in the electrical alcove.
Instead of examining the lighthouse while in the electrical alcove:
	Say "You can't see much of the lighthouse besides the alcove you're standing in.[if lively] And the marks scratched onto the wall.[paragraph break][cipher-fox][end if]".

The electrical box is in the electrical alcove.

Chapter - Lighthouse Control Panel

Section - The Socket

The socket is a fixed in place container in the lighthouse apex. The socket can be spinning. The socket is not spinning. The socket can be activated. The socket is not activated.
The burnt out bulb is in the socket.
Check inserting something (called the item) into the socket:
	If the socket is spinning:
		Say "There's no way you can stick [the item] in there while [the socket] is spinning like that.";
		Stop the action;
	If the noun is not the spare bulb and the noun is not the burnt out bulb:
		Say "The socket is designed to hold bulbs. Anything else might damage it.";
		Stop the action;
	If something is enclosed by the socket:
		Say "There's no room in the socket for [the noun].";
		Stop the action.
Check removing something (called the item) from the socket:
	If the socket is spinning:
		Say "There's no way you take [the item] from inside [the socket] while [the socket] is spinning like that.";
		Stop the action.
		
Section - The bulbs
	
To say change the bulb name:
	Now the printed name of the burnt out bulb is "burnt out bulb".
	
The burnt out bulb is a heavy thing with printed name "bulb". The description is "[first time][change the bulb name][only]A gigantic glass bulb. It's cone shaped, and easily three feet across at the big end. The glass is cracked, and the inside is all black and sooty.".
Instead of dropping the burnt out bulb:
	Say "Dropped. The bulb shatters into thousands of little pieces.";
	Remove the burnt out bulb from play;
	Now the shattered bulb is in the location of the player.
	
The shattered bulb is a thing. The description is "A pile of glass shards. They used to be a bulb for the lighthouse.";
Instead of taking the shattered bulb:
	Say "You'd just cut yourself. Best to leave it be.".

The spare bulb is a heavy thing. The description is "[if the lighthouse is blazing]It's too bright to look at.[otherwise]A gigantic glass bulb. It's cone shaped, and easily three feet across at the big end.[end if]".
Instead of dropping the spare bulb:
	Say "You set the bulb down. Gently. You can't just go about dropping it on hard things.";
	Now the spare bulb is in the location of the player.
		
		
Report taking the spare bulb when the lighthouse is blazing:
	Say "Taken. Removing the bulb is an effective way to stop the lighthouse from shining.";

Section - The Crate

The crate is a heavy closed locked lockable openable thing. 
The description of the crate is "A large wooden crate. It has a picture of a lightbulb painted on the outside[if the crate is closed]. The lid is nailed tightly shut[end if].".
The crate is in the yard.
The spare bulb is in the crate.

Instead of unlocking the crate with something:
	Try prying the crate with the second noun.
	
Instead of unlocking keylessly the crate:
	Try implicit-prying the crate.

Before opening the locked crate (This is the avoid implicit unlocking the crate rule):
	Try implicit-prying the crate;
	Stop the action.

Instead of opening the crate:
	If the crate is closed and the crate is unlocked:
		Continue the action;
	If the crate is open:
		Say "You already pryed the crate open.";
		Stop the action;
			
Instead of closing the crate:
	If the crate is closed:
		Say "You recall what you know about the crate and, yep, it's been closed this whole time.";
	Otherwise:
		Say "How? Are you going to nail the lid back on? What a waste of time.".
		
Instead of prying the crate with the prybar:
	Say "You wedge the prybar under the lid of the crate and, after a moment's effort, succeed in separating it from the rest of the crate.";
	Now the crate is not locked;
	Try opening the crate.
	
Section - Knobs

A knob is a kind of thing. A knob has a number called the current setting. The current setting of a knob is usually 0.

After examining a knob (called the knob):
	Say "The knob has three settings; X, Y and Z. It is set to [the current setting of the knob as a knob setting].".

Temp-knob-text is an indexed text that varies.
Instead of setting a knob (called the knob) to some text:
	Let the proposed setting be 3;
	Now temp-knob-text is "[the topic understood]";
	If the temp-knob-text is "X" or the temp-knob-text is "x", now the proposed setting is 0;
	If the temp-knob-text is "Y" or the temp-knob-text is "y", now the proposed setting is 1;
	If the temp-knob-text is "Z" or the temp-knob-text is "z", now the proposed setting is 2;
	If the proposed setting is less than 0 or the proposed setting is greater than 2:
		Say "'[topic understood]' is not a valid setting for [the knob].";
		Stop the action;
	If the proposed setting is the current setting of the knob:
		Say "The knob is already set to [topic understood].";
		Stop the action;
	Say "You turn [the knob] to [topic understood].";
	Now the current setting of the knob is the proposed setting.
	
After printing the name of a knob (called the knob) while examining:
	Say " (set to [current setting of the knob as a knob setting])".
		
To say (num - a number) as a knob setting:
	If num is 0, say "X";
	If num is 1, say "Y";
	If num is 2, say "Z";
	
Instead of turning a knob (called the knob):
	Increase the current setting of the knob by 1;
	If the current setting of the knob is 3:
		Now the current setting of the knob is 0;
	Say "You turn [the knob] to the next setting. Now it is set to [current setting of the knob as a knob setting].".
	
Instead of using a knob:
	Try turning the noun.
			
Section - Control Panel
		
An indicator is a kind of thing. An indicator can be lit. An indicator is usually not lit.

The control panel is a fixed in place supporter. The description is "This is a scuffed up control panel. There's a [interest]label[normal] across the top.".
The red knob is a fixed in place knob on the control panel.
The green knob is a fixed in place knob on the control panel.
The blue knob is a fixed in place knob on the control panel.
The power indicator is a fixed in place indicator on the control panel.
The control panel label is a part of the control panel. The description is "Turn knobs. Pull lever.".
The lever is a fixed in place thing on the control panel.

To decide what indexed text is the waveform:
	Decide on "[current setting of red knob as a knob setting][current setting of green knob as a knob setting][current setting of blue knob as a knob setting]";

Rule for printing the name of the power indicator while examining:
	If the power junction is complete:
		Say "[interest]power indicator[normal] (lit)";
	Otherwise:
		Say "[interest]power indicator[normal]".

Rule for printing the name of the control panel while looking:
	Say "[interest]control panel[normal]";
	omit contents in listing.
	
	
The power junction is a distant visible-at-a-distance fixed in place circuit. The red fuse completes the power junction. The description of the power junction is "There is a box on the ceiling. Wires enter it on both ends. One set of wires connects to the control panel.".
Understand "box", "junction box", "power box" as the power junction.
A distant objects rule for the power junction when the player is on the ladder: rule succeeds.
A distant objects rule for something enclosed by the power junction when the player is on the ladder: rule succeeds.
The spent fuse is in the power junction.

The control panel is in the lighthouse apex.
The power junction is in the lighthouse apex.

[Stop some ambiquation between the red fuse and red knob when manipulating lighthouse controls]
Does the player mean turning the red fuse: It is very unlikely.
Does the player mean using the red fuse: It is very unlikely.
Does the player mean setting the red fuse to: It is very unlikely.
Does the player mean turning the green button: It is very unlikely.
Does the player mean pushing the green knob: It is very unlikely.
Does the player mean setting the green button to: It is very unlikely.

Instead of pushing the lever:
	Try pulling the lever.
Instead of turning the lever:
	Try pulling the lever.
Instead of switching on the lever:
	Try pulling the lever.
Instead of switching off the lever:
	Try pulling the lever.
Instead of pulling the lever:
	Say "You pull the lever.";
	If the power junction is not complete:
		Say "Absolutely nothing happens.";
		Stop the action;
	Say "The control panel buzzes.";
	[Say "{Waveform: [the waveform]}.";]
	If the waveform is "ZYX":
		If the socket is not spinning:
			Say "The light begins to spin.";
			Now the socket is spinning;
			Stop the action;
	If the waveform is "YXZ":
		If the socket is spinning:
			Say "The light grinds to a halt.";
			Now the socket is not spinning;
			Stop the action;
	If the waveform is "XZZ":
		[Say "{Activating socket.}";]
		If the socket is not activated:
			Now the socket is activated;
			If the spare bulb is in the socket:
				Say "The lighthouse blazes to life.";
			Otherwise:
				Say "Absolutely nothing happens.";
			Stop the action;
	If the waveform is "ZZX":
		If the socket is activated:
			Now the socket is not activated;
			If the spare bulb is in the socket:
				Say "The light fades from the lighthouse.";
			Otherwise:
				Say "Absolutely nothing happens.";
			Stop the action;
	Say "Absolutely nothing happens.".
					
				
To decide if the lighthouse is blazing:
	If the power junction is complete:
		If the spare bulb is in the socket:
			If the socket is activated:
				Decide yes;
	Decide no.
	
To decide if the lighthouse is operational:
	If the lighthouse is blazing:
		If the socket is spinning:
			Decide yes;
	Decide no.

Section - Hint Objects		
					
The torn page is a thing. The description is "This appears to be a page torn out of a book. Half the page is gone, rendering the text mostly gibberish, but clear across the top is 'Lighthouse Manual v2'. You can't understand any of the actual content, but someone has written in the margin 'orange: spin, purple: stop, cyan: on, yellow: off'".

The raster graphics manual is a thing. The description is "This is a rather hefty text book about the raster graphical systems of modern computers. One of the pages is dog-eared, so naturally every time you open the book it opens at that page. It goes on a bit about color encoding schemes, particularly RGB. That's Red, Green, and Blue to the less technically inclined. Apparently two parts red to one part green makes the color Orange.".

Chapter - Test area - Not For Release

Lower test room is a holey room. 
The test portal is an enterable container in the test room.

Instead of entering the test portal:
	Now the player is in the kitchen.
[
When play begins:
	Now the player is in the lower test room.
	
Include Object Response Tests by Juhana Leinonen.

The thermite is a thing in the test room.]

Testoing is an action out of world applying to nothing.
Understand "testo" as testoing.

Carry out testoing:
	Now the player is in the lower test room.
	
Book - Characters

Chapter - Response testing - Not for release

Testing responses is an action applying to nothing.
Understand "response-test" as testing responses.

The auditorium is a room. The description is "An auditorium with perfect aucustics, made specifically for pumping everything someone knows about everything out of them.".

Carry out testing responses:
	Now the player is in the auditorium;
	Repeat with Bob running through every person:
		If Bob is not the player and Bob is not the little girl and Bob is not the eaglet and Bob is not Shoo and Bob is not the ducks and Bob is not Death:
			Now Bob is in the auditorium;
			Say "Testing [Bob][line break]";
			Repeat with widget running through every thing:
				If widget is not a puzzle and widget is not a task and widget is not a door and widget is not a hyperlink action:
					Now widget is familiar;
					Say "[Bob] about [widget][line break]";
					Try the player quizzing Bob about widget;
					Suppress listing topics.



Chapter - The player

The description of the player is "Starting from the bottom, with your feet, which are too big; your legs are too skinny, your knees are too knobby, your belly is too round, your chest is too flat, your face is too ordinary and your hair is too brown. Your mother calls this the 'awkward stage,' but your problem isn't that you're awkward. It's just that you're ugly.".

The letter is a thing with description "Dear Margret, the letter says, which is not your name; I am very much looking forward to your visit. I have prepared a room in the inn for you. I was so excited to learn that my little boy had run off and had a child, I only wish that harlot he married hadn't waited thirteen years to tell me. You're going to love it on Akkoteaque Island. There are so few interesting people to get in the way of honest work. Signed, Grandma Catherine." The player carries the letter.

The picture is a thing. The description of the picture is "This is a photograph of two people standing in front of a lighthouse. We're just going to assume it's the lighthouse on Akkoteaque. It's an old fashioned sort of lighthouse, very tall and narrow and striped in alternating bands of red and white. The picture was taken on a bright sunny day, so it's a picture of the lighthouse not being terribly useful.[paragraph break]The two people are your parents, about fifteen years younger than you remember them.[paragraph break]There's something written on the back of it, too. At least, it's probably writing. It looks like:[paragraph break][cipher-dead]".
The player carries the picture.

The skirt is a wearable thing worn by the player. The description is "[if ghostly]Your skirt is striped red and white and is of a respectable length.[otherwise]Your skirt is torn and tattered and appears to be mostly brown.[end if]".
Instead of taking off the skirt:
	Say "You would, except then people might see your bubble butt.".

The shirt is a wearable thing worn by the player. The description is "[if ghostly]'Hi-yah!' your shirt says. It has a picture of a kung-foo kangaroo on it.[otherwise]'Hurrrgh!' your shirt says. It has a picture of a flesh eating wallaby on it.[end if]".
Instead of taking off the shirt:
	Say "Well, it's not like you've got anything to hide. But still.".
	




Chapter - Mr Henrico

Henrico is a privately-named man. Henrico is proper-named. The real name is "Mr. Henrico". Henrico is introduced. The printed name of Henrico is "Mr. Henrico".
Understand "mr henrico" as Henrico.
Understand "henrico" as Henrico.
The description of Henrico is "Before you stands a short, balding, civil servant. Mr. Henrico has been your case worker for the last several months. [first time]He once told you to think of him as a father figure. You have disliked him ever since. [only]He's not particularly pleasant, but he's good at paperwork and that's probably the most important characteristic of social workers.".

Rule for writing a paragraph about Henrico:
	Say "[The Henrico] stands here looking very droll and boring.".

The ask-suggestions of Henrico are { akkoteaque, subject-grandmother, subject-mother, subject-father, subject-accident }.

Response of Henrico when asked about yourself:
	Say "'Too smart for your own good, I think,' [the Henrico] says. 'You need to work on that cynicism, too. You're far too young to be so jaded, and it won't help you in the long run.'".
Response of Henrico when asked about Henrico:
	Say "'Never really thought I was cut out for this sort of thing,' Mr. Henrico muses, as if he hadn't actually heard you ask anything. 'Going to call this one a rousing success, though.'".
Response of Henrico when asked about Akkoteaque:
	Say "'I've heard it's a very nice island,' Mr. Henrico says. 'I think you will like it there. Your grandmother will take good care of you.'".
Response of Henrico when asked about subject-grandmother:
	Say "Mr. Henrico rubs his chin. 'She seemed nice enough on the phone. You shouldn't worry about it. I'm sure the things your mother used to tell you about her were exaggeration.'".
Response of Henrico when asked about subject-accident:
	Say "'It's best not to dwell on these things,' Mr. Henrico says. 'I expect you know as much as I do already anyway. Car accident and all that. Very tragic. But lets not dwell. It won't bring your parents back.'".
Response of Henrico when asked about subject-mother:
	Say "'I never met her, you know,' Mr. Henrico says. 'I know she told you some terrible things about your grandmother, but you really shouldn't let them scare you. She's your last living relative and she's kindly offered to take you on. Isn't this fantastic?'".
Response of Henrico when asked about subject-father:
	Say "'You know I know you're still carrying around that watch. What have I told you about moving on? You'll never be able to as long as you cling to things like that.'".
Response of Henrico when asked about Shoo:
	Say "Mr Henrico takes a look at [the Shoo]. 'Yep,' he says. 'That's a pelican.'".
Response of Henrico when asked about the lighthouse:
	Say "'Don't like lighthouses,' Mr. Henrico says. 'Too tall, and too bright.'".
Response of Henrico when asked about the mackerel:
	Say "Mr. Henrico raises his brows at you. 'It's a nice fish, I guess. As far as fish go.'".
	
Response of Henrico when given the mackerel:
	Say "Mr Henrico politely refuses the offered sea creature. 'No, no,' he says. 'I'm not a fan of sushi.'".
	
Chapter - Spider

Section - Basics

Spider is a privately-named man. The real name is "Captain Spider". The printed name is "salty sea man".

Spider is not proper-named.
Spider can be restless or at peace. Spider is restless.
The description of Spider is "[Spider details]".
To say Spider details:
	If putting Spider to rest is happening:
		Say "You're a rather average man of rather average build and altogether unremarkableness, but you have excellent calves. You take a moment to admire your oddly youthful legs.";
	Otherwise:
		Say "[The Spider] chews on a [link]pipe[as]x pipe[end link] yellowed from long years of use.  He wears a long [link]beard[as]x beard[end link] on a deeply lined face. Your overall impression of [the spider] is one of shabbiness[if the spider-hook is part of Spider]. It is possible that the newest thing he wears is the brass fishing [link]hook[as]x hook[end link hilite] he has used as a button to hold his shirt closed[end if].".
The legs are a privately-named part of Spider.
Understand "calves", "legs", "youthful legs", "oddly youthful legs" as the legs when putting Spider to rest is happening. 
The description of the legs is "Look at that fantastic definition! You are truley blessed with the legs of adonis himself. They ripple like the waves on the ocean as you flex your wonderful calves.".

Understand "captain", "man", "sea man", "salty man", "salty sea man", "salty" as Spider.
Understand "spider" and "captain spider" as Spider when Spider is introduced.
The Spider-pipe is a privately-named part of Spider with printed name "pipe". The description of the Spider-pipe is "[The spider]'s pipe is carved with the creatures of the sea. Fanciful creatures, like sea cucumbers, and eels, and others of roughly the same imaginative shape. The pipe is not lit."
Understand "pipe" and "man's pipe" and "salty sea man's pipe" as the Spider-pipe.
Understand "Spider's pipe" and "Captain Spider's pipe" as the Spider-pipe when Spider is introduced.
The Spider-beard is a privately-named part of Spider. The description of the Spider-beard is "The yellow streaks in [spider]'s beard might be blond hair. Judging by the way they continue onto his shirt, they are probably mustard."
Understand "beard" and "man's beard" and "salty sea man's beard" as the Spider-beard.
Understand "Spider's beard" and "Captain Spider's beard" as the Spider-beard when Spider is introduced.
The spider-hook is a privately-named part of Spider. The spider-hook has printed name "hook". The description of the spider-hook is "It's a small brass hook. It's holding his shirt closed.". Understand "hook", "fish hook", "fishing hook", "fishhook", "fishook", "man's hook", "salty sea man's hook", "sea man's hook", "brass", "brass hook" as the spider-hook.
Understand "Spider's hook" and "Captain Spider's hook" as the spider-hook when Spider is introduced.

Does the player mean taking the spider-hook: It is very unlikely.

Rule for writing a paragraph about Spider:
	Say "[The spider] mills about, doing something to his boat. You can't tell what, but it seems to involve pushing dirt about with a rag.".
	
Rule for writing a paragraph about Spider during opening boat ride:
	Say "[The spider] stands at the controls of the ferry.".

The ask-suggestions of spider are { self-suggestion, spider-hook, Akkoteaque, ferry, subject-franklin, Shoo, subject-treasure, generator, detonator, wire, paddle fuse, ancient chest, skeleton, dynamite, slot }.


Section - Responses that advance plot

Instead of giving the gold doubloon to Spider:
	If Spider encloses the spider-hook:
		Now the hook charm is in the location of Spider;
	Hide the gold doubloon;
	Start the spider memory.
Instead of showing the gold doubloon to Spider:
	Try giving the gold doubloon to Spider.

Response of Spider when asked about Akkoteaque:
	say "'Island has always just been in the way,' [the spider] says. 'Nothing but a bunch of rocks and cliffs. They go straight up, all the way down, so when a ship hits it they don't hang around, no way. [link]Lighthouse[as]ask [printed name of Spider] about lighthouse[end link] is kind of important.'".
Response of Spider when asked about the lighthouse:
	say "[the spider] says, 'That lighthouse is the most important thing on Akkoteaque. Hell, it's the only important thing. All those ships that want to come up the river, they don't want to run into Akkoteaque. [link]Franklin[as]ask [printed name of Spider] about franklin[end link] keeps the lighthouse running.'";
	Now subject-franklin is familiar.
Response of Spider when asked about Spider:
	say "'Who, me?' [the spider] asks. 'I'm Captain Spider.  I drive the ferry back and forth. It's really boring and I hate it. Only do it cause of that [link]treasure[as]ask [printed name of spider] about treasure[end link].'";
	Introduce Spider;
	Now subject-treasure is familiar.
Response of Spider when asked about Franklin or asked about subject-franklin:
	Say "'He takes care of the [link]lighthouse[as]ask [printed name of Spider] about lighthouse[end link]. Odd guy.'".
Response of Spider when asked about subject-treasure:
	Say "'Yep, treasure. Buried right here on this island too. I know it's here because I found an [link]ancient key[as]ask [printed name of Spider] about ancient key[end link]. I know it's somewhere above that cave on the beach.. ah, I've said too much already!'";
	Now the ancient key is familiar;
Response of Spider when (asked about the backdrop-cargo-ship) and (the ferry is enclosed by the sea):
	Say "'They're on the wrong damn side of the island,' [the spider] mutters with his pipe clenched between his teeth. 'Like as not get us all killed. Didn't they see our damn lighthouse?'".
	
Section - Responses about character-specific objects
	
Response of Spider when asked about the spider-hook:
	If the spider-hook is part of Spider:
		Remove the spider-hook from play;
		Say "'Hook?' [the spider] asks. 'What hook? This? Why, this isn't even mine.'[paragraph break][The spider] removes the hook from his shirt and does up the buttons instead. He gives the hook to you.";
		Now the player holds the hook charm;
		Now the hook charm is familiar;
	Otherwise:
		Say "'I gave it to you, didn't I?'".
		
Does the player mean quizzing Spider about the spider-hook:
	If Spider encloses the spider-hook: 
		It is very likely;
	Otherwise:
		It is very unlikely.
		
Response of Spider when asked about the spider-pipe:
	say "'What, this old thing?' [the spider] asks. 'Only carved it myself. Yep. From the jaw bone of a [link]dolphin[as]ask [printed name of Spider] about dolphins[end link].'";
	now the subject-dolphins are familiar.
Response of Spider when asked about the spider-beard:
	say "[The spider] strokes his beard. 'Yep, yep, it is quite an impressive beard.'".
Response of Spider when asked about the subject-dolphins:
	say "'Vermin, I say', [the spider] says. 'But I guess they do save people who what when they fall off the cliff. Well, usually.'".
Response of Spider when asked about Shoo:
	say "[The spider] says, 'That damn bird? Laziest thing I ever saw. We all call her Shoo. As in... shoo.'";
	Introduce Shoo.
Response of Spider when asked about the ferry:
	say "[The spider] says, 'This here is my ship. Ain't much of a ship, no, but she my ship.'".
Response of Spider when asked about Delmarva:
	Say "'Deleware, Maryland, Virginia. That's all three states on the penninsula.'".
	
	
Section - Responses that hint about puzzle objects


Response of Spider when asked about the ancient key:
	Say "'That opens the treasure. I think, anyway. I found it in the caves under the inn.'".
Response of Spider when asked about the detonator:
	Say "'Not really a toy for children,' [the Spider] yarns, 'got to hook some dynamite up to tha' thing anyway. Or else what it going to 'splode?'".
Response of Spider when asked about the generator:
	Say "'Well it makes electricity, right? Get you some juice to light the place up. Kind of amazing, really. That thing turns fossil fuels into artifishal sun.'".
Response of Spider when asked about the paddle fuse:
	If the player encloses the paddle fuse:
		Say "'Oh, you found it. Well. That's good then.'";
	Otherwise:
		Say "[The Spider] scratches his beard. 'Well now, I had a spare. I must have dropped it in that cave somewhere.'".
Response of Spider when asked about the slot:
	Say "'That's no problem. Just slap a padd'l fuse in there.'";
	Now the paddle fuse is familiar.
Response of Spider when asked about the ancient chest:
	Say "'I always specu-late-ed that that there chest was somewhere under the inn. Never got there, though, old bag Catherine wouldn't let me blast.'".
Response of Spider when asked about the skeleton:
	Say "[The Spider] shifts his pipe back and forth from one side of his mouth to another. 'Spooky', he says. 'I don't know what I'd do if I found that.'".
	
Section - Responses about unrelated items

Response of Spider when asked about Alabaster:
	Say "'Some kind of tourist? I think I'd remember bringing that across.'".
	
Response of Spider when asked about the altar:
	Say "'Never knew which bit was the altar. Kinda looks like a table to me.'".
	
Response of Spider when asked about the amber bottle:
	Say "'Rum rum rum, yum yum yum! Rum rum rum, it goes in my tum! Fnar fnar!'".
	
[Ancient Chest]



Response of Spider when asked about the projector:
	If the location of Spider encloses the projector:
		Say "[The Spider] peers at [the projector]. 'It's mighty odd looking, innit? Sort of, what's that called. Steampunky.'";
	Otherwise:
		Say "'I don't think I know much about projectofiers. Don't you need to point it at a screen?'".
		
Response of Spider when asked about the nest:
	Say "'A gull's nest? In a cliff? By the ocean? Aint that somethin.'".
	
Response of Spider when asked about the gulls:
	Say "'Noisy buggers, aren't they?'".
	
Response of Spider when asked about the ducks:
	Say "'Never did like ducks. They think they are better than gulls, see, but they really aint.'".
	
Response of Spider when asked about Gerald:
	Say "'Who? I'm pretty sure I'm the only old man around here.. fnar fnar!'".
	
Response of Spider when asked about the iron gate:
	Say "'I guess the father would have the key to that. I sure don't.'".
	
Response of Spider when asked about the ladder:
	Say "'Ladder's good for climbing up to high places. Nice and portable too, that ladder.'".
	
Response of Spider when asked about the posters:
	Say "'They're nice posters, aren't they? Course, it's always wet in there, so.'".
	
Response of Spider when asked about the shack-bed:
	Say "'Stay off my bed, ya hear lass? I don't need any stories goin' round.'".
	
Response of Spider when asked about the rusty table:
	Say "'So what if it's a little rusty? It still works as a table, doesn't it?'".
	
	
	
	
	
Chapter - Shoo

Shoo is a privately-named woman. The real name is "Shoo". The printed name is "angry pelican". The description is "[shoo-description]".  
Understand "pelican", "angry pelican", "angry", "bird" as Shoo.
Understand "shoo" as Shoo when Shoo is introduced.
The indefinite article of Shoo is "an".
Shoo is not proper-named.

Shoo can be hungry, fed, watching, charming, or done. Shoo is hungry.

A room can be shoo-friendly. A room is usually not shoo-friendly.
The beach is shoo-friendly.
The garden is shoo-friendly.

Every turn when the player in the garden:
	If the location of Shoo is not the garden and the garden is shoo-friendly:
		Now shoo is in the garden;
		Say "[The shoo] swoops down over the bushes and lands with a plop.".

Every turn when the player in the beach:
	If the location of Shoo is not the beach and the beach is shoo-friendly:
		Now shoo is in the beach;
		Say "[The shoo] glides over the sand and lands nearby.".

Every turn when the player in the narrow ledge:
	If the location of Shoo is not the narrow ledge and narrow-ledge-shoo-state is 0:
		Now shoo is in the narrow ledge;
		Say "[The shoo] sails in off the sea and lands on the ledge.".

To say shoo-description:
	If Shoo steals the watch is happening, say "This bird is standing on your chest and staring at you. It has tiny, glaring little eyes that you make you want to [link]hit it right in the face[as]hit pelican[end link].";
	Otherwise say "You're pretty sure birds can scowl. You're looking at one doing it right now.[if Shoo is not hungry][run paragraph on] Half a fish hangs from the pelican's beak. Normally, this situation would make a pelican pretty happy. Not this pelican.[end if]".

Rule for writing a paragraph about Shoo:
	Say "[The shoo] swivels its head back and forth, peering at you from many angles.".

Response of Shoo when asked about anything:
	Say "[The shoo] does not respond. [The shoo] is a bird.";
	Suppress listing topics.

Feed-Shoo-The-Fish is a projected hyperlink action with printed name "[if the active item is Shoo]feed her the [printed name of the active fish of Feed-Shoo-The-Fish][otherwise if the active item is a fish]feed [printed name of the active fish of Feed-Shoo-The-Fish] to the pelican[otherwise]feed the [printed name of the active fish of Feed-Shoo-The-Fish] to the pelican[end if]" and command text "feed [printed name of the active fish of Feed-Shoo-The-Fish] to pelican".
Feed-Shoo-The-Fish has an object called the active fish.
Action fruitful for Feed-Shoo-The-Fish:
	If the player does not enclose a fish:
		Rule fails;
	Otherwise:
		Let F be a random fish enclosed by the player;
		Now the active fish of Feed-Shoo-The-Fish is F.
		
The special actions of Shoo are { Feed-Shoo-The-Fish }.
The special actions of a fish are { Feed-Shoo-The-Fish }.

Response of Shoo when given the fish-head:
	Say "[The shoo] expresses her disdain for eating a fish head she herself puked out. By glaring at you.".
	
Instead of hitting shoo (this is the don't hit shoo rule):
	Say "[The shoo] steps back just far enough to dodge your blow. She glares at you. Angrily.".
	
Instead of hitting shoo when the location of the ducks is the location of shoo and the ducks are lively (this is the ravens block shoo dodging rule):
	If shoo is watching:
		Say "[The shoo] moves to dodge your blow, but with those ravens pestering her she never has a chance. You connect with a solid blow. [The shoo] squaks, and spews out her lunch, including your [link]pocket watch[as]x pocket watch[end link]. Her regurgitated lunch is enough to distract the ravens, and [the shoo] makes her escape.";
		Now the pocket watch is in the location of Shoo;
		Now Shoo is charming;
		Now the location of shoo is not shoo-friendly;
		Now shoo is in the narrow ledge;
	Otherwise if shoo is charming:
		Say "[The shoo] moves to dodge your blow, but with those ravens pestering her she never has a chance. You connect with a solid blow. [The shoo] squaks, and this time up comes her breakfast. Amongst the half digested fish is a tiny [link]pelican charm[as]x pelican charm[end link]. Her regurgitated breakfast is enough to distract the ravens, and [the shoo] makes her escape.";
		Now the pelican charm is in the location of Shoo;
		Now Shoo is done;
		Now the location of shoo is not shoo-friendly;
		Now shoo is in the narrow ledge;
	Otherwise:
		Say "This should be unreachable.".
		
Shooing is an action applying to one thing.
Understand "shoo [something]" as shooing.
Check shooing:
	Say "[The noun] stays right where it is.".
	
Shooing-points-awarded is a truth-state that varies. Shooing-points-awarded is false.
Check shooing Shoo:
	Say "[The shoo] looks at you over her immense beak. Really, she seems to say.";
	If Shooing-points-awarded is false:
		Now Shooing-points-awarded is true;
		Award 1 point with message "1 point for being ignored utterly by that damn bird".
		
	

Chapter - Alabaster

Section - Basics 

Alabaster is a hidden privately-named man. The real name is "Alabaster". The printed name is "portly tourist".
The description of Alabaster is "[The Alabaster] stands there with his thumbs tucked into his suspenders. He's best described as round. In fact, since that's best, I should stop there, but I'll add one more: He's also rotund.".
Understand "tourist", "portly tourist", "man" as Alabaster.
Understand "alabaster" as Alabaster when Alabaster is introduced.
Alabaster is not proper-named.

Rule for writing a paragraph about Alabaster:
	Say "[The Alabaster] stands with his thumbs hooked through his suspenders. Occasionally he snaps them against his flesh.".

Section - Responses that advance plot

The ask-suggestions of Alabaster are { self-suggestion, ghosts, lighthouse, akkoteaque, projector, subject-grandmother, Spider, Franklin, subject-elizabeth, subject-gerald }.
Asked-Alabaster-About-Ghosts is a truth state that varies. Asked-Alabaster-About-Ghosts is false.


Response of Alabaster when asked about Alabaster:
	Say "'Alabaster is the name. Alabaster of Alabaster Plaster. Of course, the name was White before we got into the business.'";
	Introduce Alabaster.
Response of Alabaster when asked about the projector:
	Say "'My etho-projectofier,' [the alabaster] says. 'It lets me peer into the world of the dead and speak with [link]ghosts[as]ask tourist about ghosts[end link]!'";
	Now the printed name of the projector is "etho-projectofier";
	Now the ghosts are familiar.
Response of Alabaster when asked about akkoteaque:
	Say "'I'd heard that this is the most haunted island in Delmarva. So naturally I came here to look for the [link]ghosts[as]ask tourist about ghosts[end link].'";
	Now the ghosts are familiar.
Response of Alabaster when asked about the lighthouse:
	Say "'The lighthouse is only one reason tourists come to this island. There's also the [link]ghosts[as]ask tourist about ghosts[end link].'";
	Now the ghosts are familiar.
Response of Alabaster when asked about the ghosts:
	Say "'I've heard of four on this island... though I've only seen one.'[paragraph break][The alabaster] tucks his thumbs through his belt. 'There's the Captain. That's what the old woman upstairs calls him. And the sad woman. And the engineer. I think the lighthouse holds him here. That's the thing about ghosts. They always stick around for a reason. There's also the girl.[paragraph break]'The strangest thing is, of all the ghosts I've met over the years, non have ever realized they were dead. They've all forgotten how it happened! As soon as you remind them, they go poof, so I try not to.'";
	If Asked-Alabaster-About-Ghosts is false:
		Add Spider to the ask-suggestions of Alabaster;
		Add Franklin to the ask-suggestions of Alabaster;
		Add Elizabeth to the ask-suggestions of Alabaster;
		Add the little girl to the ask-suggestions of Alabaster;
		Now the little girl is familiar;
		Now Asked-Alabaster-About-Ghosts is true;
Response of Alabaster when asked about the subject-grandmother:
	Say "'I guess that'd be the septuagenarian that ran this place. She's upstairs, but take this bit of advice: She's not a conversationalist.'".

Response of Alabaster when asked about Franklin:
	Say "'Ah, Franklin. He was the engineer from the coast guard assigned to the lighthouse. I've heard conflicting reports, but they all agree that he haunts the lighthouse itself.'";
	Introduce Franklin.
Response of Alabaster when asked about Spider:
	Say "[The Alabaster] nods knowingly. 'Of course you've met the Captain. Everyone seems to run into him. He used to drive the ferry back and forth until one day, he just vanished. Now he seems to flit about the jetty. I've heard he always stays close to the ferry, though it's a bit of a mess nowadays.'".
Response of Alabaster when asked about Elizabeth:
	Say "'That one is almost a rather tragic story of lost love. I say almost because she was thirty five when she drowned and he was sixty two. It doesn't make any sense to me, unless he's secretly rich.. He'd be Gerald. He comes about the island quite frequently, despite being well into his eighties.' [The alabaster] rubs his chins. 'He's quite a fountain of information if you can get him talking.'".
Response of Alabaster when asked about Gerald:
	Say "'I think he's probably coming over to the island on important dates. Like their aniversary. Anyway, he's here now so you could just ask him yourself.'".
Response of Alabaster when asked about the little girl:
	Say "'She's the hardest to spot of the four ghosts that supposably haunt this place. In fact, noone has actually seen her. She's supposably something of a poltergeist.' [The alabaster] rubs his hands together gleefully. 'She'll be my first poltergeist if I can actually find her. She doesn't seem to be tied to any place on the island.'".
	
Section - Character specific responses

Section - Miscelaneous responses



Chapter - Brisbane

Section - Basics

Brisbane is a privately-named man. The real name is "Father Brisbane". The printed name is "hunched priest". The description is "[brisbane details]".
Brisbane is not proper-named.
Understand "man", "hunched", "priest", "hunched priest" as Brisbane.
Understand "father", "brisbane", "father brisbane" as Brisbane when Brisbane is introduced.

The ask-suggestions of Brisbane are { self-suggestion, iron gate, Spider, Franklin, Elizabeth, Gerald, Catherine, Ilana, Death, Alabaster }.

First response of Brisbane when Brisbane is ghostly (This is the can't hear brisbane when ghostly rule):
	Say "[The Brisbane] answers, but all you hear are whispers.".
	
Section - Drunkedness

Brisbane can be bs-A, bs-B, bs-C, or bs-D. Brisbane is bs-A.
[These states translate as follows:
	A: At his desk in the chapel office.
	B: Challenging Death, with his aspergillum.
	C: Challenging Death, without his aspergillum.
	D: Post-challenge.
]

Brisbane has a number called drunkedness. The drunkedness of Brisbane is 0.

To say brisbane details:
	Say "[The Brisbane] is a shabby priest wearing a patched black coat and a grey collar. The collar is probably meant to be white.[run paragraph on]";
	If Brisbane holds the crystal glass and Brisbane holds the aspergillum:
		Say " He clutches [a crystal glass] in one hand and [an aspergillum] in the other.[run paragraph on]";
	Otherwise if Brisbane holds the crystal glass:
		Say " He clutches [a crystal glass] in one hand.[run paragraph on]";
	If the drunkedness of Brisbane is greater than 4:
		Say " He appears to be pretty drunk. You can't say if he is pretty sober or not.[run paragraph on]";
	Say "[paragraph break]".

To say drunkedness verb:
	If the drunkedness of Brisbane is less than 3:
		say "stands";
	Otherwise if the drunkedness of Brisbane is less than 5:
		say "slumps";
	Otherwise:
		say "sits".
	
Instead of pouring the amber bottle into the crystal glass:
	If the crystal glass is not empty:
		Say "There's already some [the liquid of the crystal glass] in there.";
	Otherwise:
		If the amber bottle is empty:
			Say "The bottle is empty.";
		Otherwise:
			Say "You pour some amber liquid into [the brisbane]'s glass.";
			Now the liquid of the crystal glass is amber liquid;
			Decrease the amount left of the amber bottle by 1;
			If the amount left of the amber bottle is 0:
				Say "The bottle is empty now.";
				Now the liquid of the amber bottle is no-liquid.
				
Instead of pouring the communion wine into the crystal glass:
	If the crystal glass is not empty:
		Say "There's already some [the liquid of the crystal glass] in there.";
	Otherwise:
		If the communion wine is empty:
			Say "The wine bottle is empty.";
		Otherwise:
			Say "You pour some communion wine into [the brisbane]'s glass.";
			Now the liquid of the crystal glass is wine;
			Decrease the amount left of the communion wine by 1;
			If the amount left of the communion wine is 0:
				Say "The wine bottle is empty now.";
				Now the liquid of the communion wine is no-liquid.
	
Every turn when Brisbane is in the chapel and the player is in the chapel:
	If the liquid of the crystal glass is not no-liquid:
		If the drunkedness of Brisbane is 5:
			Say "[The brisbane] notices the full drink in his hand but just eyes it. Even he knows when he's had enough.";
			Increase the drunkedness of Brisbane by one;
		Otherwise:
			Say "[The brisbane] notices the full drink in his hand and empties it again.";
			Increase the drunkedness of Brisbane by one;
			If the drunkedness of Brisbane is 5:
				Say "[The brisbane] drops to a seat with a humph. The bone key falls out of his pocket.";
				Now the bone key is in the location of the player;
				Now the liquid of the crystal glass is no-liquid;
			Otherwise if the drunkedness of Brisbane is greater than 5:
				If a random chance of 1 in 3 succeeds:
					Say "[The brisbane] notices the full drink in his hand, but even he knows when he's had enough.";
			Otherwise if the drunkedness of Brisbane is greater than 2:
				say "He looks like he's about ready to fall down.";
				Now the liquid of the crystal glass is no-liquid;
	Otherwise:
		Say "[The brisbane] examines his empty glass with just a touch of remorse.".
		
		


Rule for writing a paragraph about Brisbane:
	If Brisbane is bs-A:
		Say "[The Brisbane] sits behind his desk.";
	Otherwise:
		Say "[The Brisbane] [drunkedness verb] by the door of the chapel.".
		
Brisbane holds the bone key.

Section - Responses that advance plot

Response of Brisbane when asked about Brisbane:
	If Brisbane is bs-A:
		If Brisbane is introduced:
			Say "'I'm pretty sure that this assignment is some sort of punishment. I wouldn't leave now, of course.'";
		Otherwise:
			Say "'I'm just a humble priest, child. They call me Father Brisbane, naturally, but it's such an odd title. Eighty year old women calling me Father,' [the Brisbane] says.";
			Introduce Brisbane;
	Otherwise if Brisbane is bs-B:
		Say "'Confidence comes from the power of Christ,' [the brisbane] says. 'At least, that's what I tell myself. Right now it's coming from holy water.'";
	Otherwise if Brisbane is bs-C:
		Say "'Confidence comes from the power of Christ,' [the brisbane] says. 'But I could use a little something extra right now.'";
	Otherwise: [bs-D]
		If Brisbane is introduced:
			Say "'I guess this is the way it's going to be, huh? Well, go along then.'";
		Otherwise:
			Say "'Don't you find it strange that eighty year old women call me 'Father'? It's Father Brisbane, by the way. A title I'm hardly deserving of.'";
			Introduce Brisbane.
			
Response of Brisbane when asked about the iron gate:
	If Brisbane is bs-A:
		Say "'The graveyard isn't safe. I'm not letting anyone in until I can get the fence fixed,' [the brisbane] says. 'Well, unless they die, of course.'";
	Otherwise if Brisbane is bs-B:
		Say "'I won't be giving you the key to that gate.'";
	Otherwise if Brisbane is bs-C:
		Say "'The other's think I'm mad, you know. I can't give you the key, or they'd be right.'";
	Otherwise:
		Say "'Well, go on then. This is goodbye, I suppose.'".

Response of Brisbane when asked about Spider:
	Say "'I always liked the captain,' [the brisbane] says. 'Very animated character. He was always searching for his treasure, but he never found it.'".
Response of Brisbane when asked about Franklin:
	Say "'The coast guard was not friendly to Franklin. Neither was the church, to be honest. He loved the lighthouse, though. He could never rest unless it was working properly.'".
Response of Brisbane when asked about Elizabeth:
	Say "'Everyone just assumed Gerald was rich, but there was real love I saw in that woman's eyes. Gerald had already paid for my services.'".
Response of Brisbane when asked about Gerald:
	Say "'He's turned into a bit of an old codger, hasn't he?'".
Response of Brisbane when asked about Catherine:
	Say "'She blames herself. It's not rational, but these things never are.'".
Response of Brisbane when asked about Ilana:
	Say "'Catherine does not make her job easy. I don't think anyone could do it better than Ilana does.'".
Response of Brisbane when asked about Death:
	Say "'Everyone has to face him eventually. Even me. Even you.'".



Section - Miscelaneous responses
	
		
Chapter - Catherine

Catherine is a hidden privately-named woman. The real name is "Your grandmother". The printed name is "old woman". The description is "[The Catherine] could quite properly be labeled 'ancient'. She has likely seen the rise and fall of multiple civilizations, and participated in some. She has a plain, deeply lined face under a mop of curly white hair, and two skeletal hands. That's all you can see of her, because she's lying in the bed covered up to her chin.".
The indefinite article of Catherine is "an".
Understand "woman", "old", "old woman" as Catherine.
Understand "grand", "grandmother", "your grandmother", "my grandmother" as Catherine when Catherine is introduced.
Catherine is not proper-named.

The subject-grandmother is a familiar proper-named subject with printed name "your grandmother". Understand "grandmother", "your grandmother", "grandma", "my grandmother" as the subject-grandmother.

The associated subject of Catherine is the subject-grandmother.

Catherine can be awake or asleep. Catherine is asleep.

Rule for writing a paragraph about Catherine:
	Say "[The Catherine] lies in the [old bed], covered up to her chin. Her eyes follow you about the room.".
	
Catherine can be coherent or incoherent. Catherine is incoherent.

The ask-suggestions of Catherine are { self-suggestion, handful of letters }.

The expanded-catherine-list is a list of objects which varies.
The expanded-catherine-list is { subject-mother, subject-father, subject-accident, henrico }.

To expand the catherine list:
	Repeat with item running through the expanded-catherine-list:
		Add item to the ask-suggestions of Catherine, if absent.
		
To say incoherent response:
	Say "[one of]'Illena?' [the catherine] asks, 'Did you shrink?'[or]'Get out of the light!'[or]'You know I was quite a looker in my youth,' [the catherine] says. 'I looked at this and that and everything.'[or]'Spiders! Spiders crawling under the house!' [the catherine] shouts.[or]'Franky.. he's got the rope again.'[or]'I saw the ferry go by the window. The storm was so strong.'[or][The catherine] glares at you.[or][The catherine] chews her gums, in that way the very incredibly old have.[or]'It sank! It sank!'[or]'Megan,' [the catherine] says.[at random]".

Response of Catherine when asked about the handful of letters:
	If Catherine is incoherent:
		Say "'Letters? Letters?' [if the player encloses the handful of letters][The Catherine] claws at the letters in your hand.[run paragraph on][otherwise][The Catherine] glares at her wardrobe.[run paragraph on][end if] A bit of life seems to return to her eyes. 'I wrote letters to my grand daughter every month. Every month for years! And they always came back! The few that didn't, she didn't reply to anyway!'[paragraph break]";
		Now Catherine is coherent;
	Otherwise:
		Say "'I wrote letters to my grand daughter every month for years. You look a little like her, actually' [the catherine] says.".
		
Response of Catherine when asked about something:
	If Catherine is incoherent:
		Say "[incoherent response]";
	Otherwise:
		Say "[The catherine] doesn't have anything specific to say about that.".
	
	
Section - Death

Death is a privately-named man. The real name is "Death". The printed name is "hooded man". The description is "[if Death is ghostly][The death] wears a long rain coat with a hood that hides his face. He's giving off some sort of vibe. You aren't sure which kind, but it's not the kind that makes you want to go and hug him. It's probably best to leave him alone.[otherwise][The death] wears a long black robe with a deep hood. Under that hood where the he should have a face is instead a skull. Empty eye sockets somehow see everything and he grins without lips.'[end if]".
Understand "hooded man", "hooded", "man", "hood", "dark", "dark hood", "hood man", "man in hood", "man in dark hood", "man in dark"  as Death.
Understand "death" as Death when Death is introduced.
Death can be indifferent or piqued. Death is indifferent.
Death is not proper-named.

Rule for writing a paragraph about Death:
	If Death is ghostly:
		Say "[The death] stands here in a black rain coat with the hood concealing his face.";
	Otherwise:
		Say "[The death] stands here in a long black robe that fails to hide his skeletal face.".
		
Response of Death when asked about anything and death is indifferent:
	Say "[The death] ignores you."
	
Response of Death when asked about the ghosts:
	Say "'Four are doomed to wander forever,' [the death]'s voice rattles likes bones bouncing together. 'Four can escape their fate.'[paragraph break][if Spider is restless]'The man of the sea is bound to his ship.'[otherwise]'The ferry man is with his long-dead wife.'[end if][paragraph break][if Elizabeth is restless]'The woman has never liked lighthouses. She must stand beneath one for eternity.'[otherwise]'The woman waits for her husband and his charms.'[end if][paragraph break][if Franklin is restless]'The engineer will never forgive himself. He toils forever to fix what he cannot.'[otherwise]'The lighthouse does not need the engineer, and he does not need it.'[end if][paragraph break]'The little girl... she will come to me last of all.'".
	
Section - Ducks

The ducks are a privately-named person.
The printed name of the ducks is "[if the ducks are ghostly]raft of ducks[otherwise]congress of ravens[end if]".  
The description of the ducks is "[if the ducks are ghostly]A small group of ducks. There appears to be a [link]leader[as]x leader[end link] duck, and several subordinate ducks. There's an entire duck hierarchy involved here. Beyond their rigid social structure, they are ordinary looking ducks. Sort of brownish, webbed feet, other things associated with ducks.[otherwise]A group of ravens, all black and staring at you. They bob and weave so there is always a different raven at the front. They seem to argue a lot, too.[first time] One of them appears to be engaged in a filibuster.[only][end if]".
Understand "ducks", "raft", "raft of ducks" as the ducks when the ducks are ghostly.
Understand "ravens", "congress", "congress of ravens" as the ducks when the ducks are lively.
The ducks have some text called the simple name. The simple name of the ducks is "[if the ducks are ghostly]ducks[otherwise]ravens[end if]".
The ducks are not proper-named.
The ducks are plural-named.
The noise of the ducks is "[if the ducks are ghostly]quacking, quacking, and more quacking[otherwise]an occasional raucous caw[end if]".

The leader is a privately-named fixed in place part of ducks. The printed name of the leader is "leader of the ducks". The description is "The leader of the ducks is not the largest duck. Or the smartest. Or the most attractive. The leader is the duck most willing to peck other ducks right in the face.".
Understand "leader", "leader of the ducks" as the leader when the ducks are ghostly.

Instead of taking the ducks, say "The [simple name of the ducks] scamper out of your reach."

The duck feeder is a person that varies. The duck feeder is Elizabeth.

Every turn:
	If the duck feeder is in the overworld:
		If the location of the duck feeder is not the location of the ducks:
			Let the right direction be the best route from the location of the ducks to the location of the duck feeder;
			Try the ducks going the right direction.

Instead of giving the loaf of bread to the ducks:
	Say "You peel off a slice and throw it to the [simple name of the ducks].";
	Now the duck feeder is the player.
	
Rule for writing a paragraph about the ducks:
	If the ducks are lively and the location of the ducks is the location of shoo:
		Say "The [simple name of the ducks] wheel and dives in the air about [the shoo], harrying her from all sides. [The shoo] stabs at them with her long beak, but at every place she snaps, she finds naught but air.";
		Now shoo is not marked for special listing;
	Otherwise:
		If the player is the duck feeder:
			Say "The [link][simple name of the ducks][as]x [simple name of the ducks][end link] have taken you in as one of their own. They cluster around you, staring expectantly[if the ducks are ghostly]. The [link]leader[as]x leader[end link] will get first selection of anything you deign to feed them, of course[end if].";
		Otherwise if the player encloses the loaf of bread:
			Say "There is a [ducks] here. They have spotted you, and taken a keen interest.";
		Otherwise:
			Say "There is a [ducks] here. They seem preoccupied with their own internal politics and haven't any attention to spare for you.".
			
Every turn when the ducks are lively and the location of the ducks is the location of shoo:
	Say "[one of]A raven lands a solid blow on [the shoo] by dive bombing the pelican's backside.[or][The shoo] nearly gets one of the ravens, but ends up with nothing but a beak full of feathers.[or]The ravens circling [the shoo] definitely have her full attention.[or][The shoo] squaks her defiance at the ravens, but only gets caws for answers.[purely at random]".
			
Response of the ducks when asked about anything:
	If the ducks are ghostly:
		Say "[one of]'Quack', says the leader of the ducks. The others nod in solemn agreement.[or]The leader of the ducks checks with a few of his subordinates before responding. 'Quack', he says.[or]A lone quack emits from one of the lesser ducks. The leader glares about but can't seem to tell who did it.[or]'Quack!' quack the ducks in chorus. 'Quack quack quack!' the leader quacks, trying not to be quacked over.[in random order]";
	Otherwise:
		Say "'Caw! Caw! Caw!' quoth the ravens.".
		
		


Chapter - Elizabeth 

Subject-gerald is an unfamiliar subject with printed name "Gerald". Understand "gerald" as subject-gerald.

Subject-elizabeth is an unfamiliar subject with printed name "Elizabeth". Understand "elizabeth" as subject-elizabeth.
The engagement ring is a wearable thing. The description is "It's a silver ring with a small green gemstone.".

Elizabeth is a privately-named woman. The real name is "Elizabeth". The printed name is "somber woman". The description is "[Elizabeth details]".

To say elizabeth details:
	If putting elizabeth to rest is happening:
		Say "You are rather wet. This is to be expected, as you are currently in the middle of the sea and quite likely to drown.";
	Otherwise:
		Say "This woman wears a wide [link]sun hat[as]x sun hat[end link], a nondescript pale dress, and a very grim expression. Her [link]nose[as]x nose[end link] combines with the set of her mouth in a very unfortunate way. It's not hard to imagine that her hat is pointy, and her cheeks warty.[If the bracelet is worn by Elizabeth] She's wearing a silver [bracelet].[end if]".
		
Elizabeth can be restless or at peace. Elizabeth is restless.
The associated subject of Elizabeth is subject-elizabeth.
Elizabeth is not proper-named.
Understand "somber woman", "woman" as Elizabeth.
Understand "elizabeth" as Elizabeth when Elizabeth is introduced.
The elizabeth-hat is a privately-named thing. The printed name is "sun hat". The description is "It is the sort of hat a tourist thinks they have to wear in the sun just because it has 'sun' in the name. Actually the hat would function perfectly well at its intended purpose; that is, hiding [the elizabeth]'s bad hair day; even under overcast skies." Understand "hat", "sun hat" as the elizabeth-hat. Elizabeth wears the elizabeth-hat.
The elizabeth-nose is a privately-named part of Elizabeth. The description is "She probably has a hard time taking that nose on airplanes." Understand "nose" as the elizabeth-nose.

Give-Elizabeth-A-Charm is a hyperlink action with printed name "give a charm to her".
Give-Elizabeth-A-Charm has a charm called the active charm. 
Action fruitful rule for Give-Elizabeth-A-Charm:
	If the player encloses a charm:
		Let C be a random charm enclosed by the player;
		Now the active charm of Give-Elizabeth-A-Charm is C;
		Now the printed name of Give-Elizabeth-A-Charm is "give the [printed name of active charm of Give-Elizabeth-A-Charm] to her";
		Now the command text of Give-Elizabeth-A-Charm is "give [printed name of active charm of Give-Elizabeth-A-Charm] to [printed name of Elizabeth]";
		Rule succeeds;
	Rule fails.
	
Special actions of Elizabeth are { Give-Elizabeth-A-Charm }.

Rule for writing a paragraph about Elizabeth:
	Say "[The elizabeth] hides herself under her wide sun hat. Every time you look at her, she's just then turning away.".
	
Subject-charms is an unfamiliar subject with printed name "charms". Understand "charms" as subject-charms.

The ask-suggestions of Elizabeth are { self-suggestion, elizabeth-hat, subject-gerald, the bracelet, the lighthouse, subject-charms, the fire hydrant charm, the lighthouse charm, the hook charm, the thimble charm, the pelican charm, the slipper charm, the engagement ring }.

Does the player mean quizzing Elizabeth about the spider-hook: It is very unlikely.
Does the player mean quizzing Elizabeth about the hook charm: It is very likely.
Does the player mean implicit-quizzing the spider-hook when the current interlocutor is not Spider: It is very unlikely.

Response of Elizabeth when asked about Elizabeth:
	Say "'Who, me? I'm Elizabeth, if it's that important to you.'";
	Introduce Elizabeth.
Response of Elizabeth when asked about the elizabeth-nose:
	Say "[The elizabeth] glares at you. 'You're rather rude, aren't you?'".
Response of Elizabeth when asked about the elizabeth-hat:
	Say "'This old thing?' [the elizabeth] asks. 'Just something [link]Gerald[as]ask [the printed name of elizabeth] about gerald[end link] bought for me.'";
	Now subject-gerald is familiar.
Response of Elizabeth when asked about subject-gerald:
	Say "[One of]'He does love his [link]lighthouses[as]ask [the printed name of elizabeth] about lighthouse[end link].. that's why we're here,' [the elizabeth] says.[or]'He will be over on the next ferry,' [the elizabeth] says. 'He had some last minute errand. I guess I'll go settle in at the inn.'[cycling]".
Response of Elizabeth when asked about Gerald:
	Say "'Don't be ridiculous. He hasn't even arrived on the island yet, how could you have met him?'".
Response of Elizabeth when asked about the bracelet:
	If Elizabeth wears the bracelet:
		Say "'It's a charm bracelet. But it's a poor one, and not very charming. I've lost all the [link]charms[as]ask [the printed name of elizabeth] about charms[end link].'[paragraph break][The Elizabeth] sighs.";
		Now the subject-charms is familiar;
	Otherwise:
		Say "'I hope you're making better use of it than I was. I don't think Gerald ever forgave me for losing all the charms. Have you found any [link]charms[as]ask [the printed name of elizabeth] about charms[end link]?'";
		Now the subject-charms is familiar;
		Now the subject-gerald is familiar.
Response of Elizabeth when asked about the lighthouse:
	Say "'[link]Gerald[as]ask [the printed name of Elizabeth] about gerald[end link] loves lighthouses. Sometimes I wonder if he loves them more than he loves me.'";
	Now subject-gerald is familiar.
Response of Elizabeth when asked about the subject-charms:
	If the player encloses a charm:
		Let C be a random charm enclosed by the player;
		Say "'Oh! You've found my [C],' [the Elizabeth] says. [run paragraph on]";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Let X be the number of charms enclosed by the player;
	Let Y be the number of charms;
	Let Z be Y - X;
	Say "'There were quite a few of them, but I've lost them all[If the player encloses a charm]. It looks like you've got all but [Z in words] of them[end if].'";
	Repeat with C running through every charm:
		Now C is familiar.
Response of Elizabeth when asked about the fire hydrant charm:
	If the fire hydrant charm is handled:
		Say "'It was where? In a bird's nest?'";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Otherwise:
		Say "'That one was stolen by a sea gull. I was feeding it, and it swept down, and took the charm right off my wrist!'".
Response of Elizabeth when asked about the hook charm:
	If the hook charm is handled:
		Say "'The ferry captain had it? I must have dropped it before I even got to the island.'";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Otherwise:
		Say "'I think I dropped that one on the ferry. It probably didn't even make it to the island.'".
Response of Elizabeth when asked about the thimble charm:
	If the thimble charm is handled:
		Say "'Right where I thought it was.'";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Otherwise:
		Say "'Oh, I know where that one is,' [the elizabeth] says. 'It's in our room at the inn.'".
Response of Elizabeth when asked about the pelican charm:
	If the pelican charm is handled:
		Say "'You have that damn bird a good smack for me?'";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Otherwise:
		Say "'It was eaten by a pelican. Yes, I know.'".
Response of Elizabeth when asked about the slipper charm:
	If the slipper charm is handled:
		Say "'Where was it? Well, she must have found it in the garden then.'";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Otherwise:
		Say "'That was the very last one I had. I last saw it in that garden behind the inn.'".
Response of Elizabeth when asked about the lighthouse charm:
	If the lighthouse charm is handled:
		Say "'An eagle? I guess they like shiney things too.'";
		If Elizabeth encloses the bracelet:
			Grant the bracelet;
	Otherwise:
		Say "'I think I lost that one while we were touring the lighthouse. I had it on the way up and didn't on the way down.'".


Instead of showing a charm (called the item) to Elizabeth:
	Try giving the item to Elizabeth.
	
Instead of giving a charm (called the charm) to Elizabeth:
	If Elizabeth wears the bracelet:
		Say "'That's one of my lost charms! [The charm]!' [the Elizabeth] exclaims. [run paragraph on]";
		Grant the bracelet;
	Otherwise:
		Say "'That's wonderful. Let me see the bracelet again if you manage to find all of them.'".
		
To grant the bracelet:
	Say "'You're obviously doing a better job with them than I was. You should have the entire thing, then.'[paragraph break][The Elizabeth] removes the [bracelet] and hands it to you.";
	Now the player holds the bracelet;
	Award 4 points with message "4 points for acquiring the charm bracelet".
		
Instead of giving the engagement ring to Elizabeth:
	Hide the engagement ring;
	Start the Elizabeth memory.
Instead of showing the engagement ring to Elizabeth:
	Try giving the engagement ring to Elizabeth.
Instead of quizzing Elizabeth about the engagement ring:
	Try giving the engagement ring to Elizabeth.
	
	
	
Chapter - Gerald
	
Section - Basics

Gerald is a privately-named man. Gerald is in the square. Gerald is hidden. The real name is "Gerald". The printed name is "old man". 
Gerald is not proper-named.
Understand "man", "old man" as Gerald.
Understand "gerald", "gerry" as Gerald when Gerald is introduced.
The associated subject of Gerald is subject-gerald.
	
Rule for writing a paragraph about Gerald:
	Say "[The Gerald] stands here staring off at the lighthouse.".
	
Section - Plot Advancement
	
The ask-suggestions of Gerald are { self-suggestion, subject-elizabeth, the bracelet, the lighthouse }.

Response of Gerald when asked about the bracelet:
	If Gerald encloses the bracelet:
		Say "'How can I thank you? It's almost as if you've given her back to me, for just a moment.'";
	Otherwise:
		If the bracelet is complete:
			Say "'That is the one I bought for Elizabeth! Where did you find it?'[paragraph break][The gerald] holds out his hand, and you hand the bracelet over.";
			Give Gerald the bracelet;
		Otherwise:
			Say "'Is that the same one I bought for my girl?' [the gerald] asks. 'It can't possibly be.'".
Response of Gerald when asked about Gerald:
	If Gerald is introduced:
		Say "'My name hasn't changed, girl,' [the gerald] says.";
	Otherwise:
		Introduce Gerald;
		Say "'Gerald. Elizabeth used to call me Gerry.' [the gerald] sighs. 'But you can't. Understand?'";
		Now subject-elizabeth is familiar.
Response of Gerald when asked about subject-elizabeth:
	Say "'She was my girl. Before.. you know.'".
Response of Gerald when asked about Elizabeth:
	Say "'Don't tease me, girl. Especially not about that,' [the gerald] says.".
Response of Gerald when asked about the lighthouse:
	Say "'I used to love lighthouses. This one has lost it's charm, though,' [the gerald] muses.".
	
Every turn when the bracelet is complete:
	If Gerald does not enclose the bracelet:
		Add the bracelet to the ask-suggestions of Gerald, if absent.	
	
Instead of giving the bracelet to Gerald:
	If the bracelet is complete:
		Give Gerald the bracelet.
		
To give Gerald the bracelet:
	Now Gerald wears the bracelet;
	Now the player holds the engagement ring;
	Say "[The Gerald] takes the bracelet and holds it up to examine it more closely. 'Impossible,' [the gerald] says. 'Elizabeth was wearing this bracelet the night the ferry.. here, you'll make better use of this. Maybe some day you can give it to a man you like.'[paragraph break][The gerald] hands you [an engagement ring].".

	
Chapter - Franklin

Franklin is a privately-named man. The real name is "Franklin". The printed name is "greasy engineer".
Franklin can be restless or at peace. Franklin is restless.
Understand "engineer", "greasy engineer", "greasy" as Franklin.
Understand "franklin", "frank", "lin" as Franklin when Franklin is introduced.
Franklin is not proper-named.

The subject-franklin is a privately-named proper-named unfamiliar subject with printed name "Franklin". Understand "franklin" as the subject-franklin.
The associated subject of Franklin is the subject-franklin.

Franklin holds the maintenance key.

Rule for writing a paragraph about Franklin:
	Say "[The Franklin] is over in the corner fiddling with some wiring of some kind.".

The description of Franklin is "[If putting Franklin to rest is happening]Looking down at yourself would also involve looking down. You have no intention of doing either.[otherwise][The franklin] is a thin man swimming around in his own clothes. His hair is slicked back with machine grease and his coat and pants are covered in streaks of grime.[end if]".

The ask-suggestions of Franklin are { Franklin, lighthouse, elevator, iron key, socket, control panel, power junction, burnt out bulb, spare bulb, green fuse, red fuse, electrical box }.

Response of Franklin when asked about the spare bulb:
	Say "'I try to keep several spares on hand just in case. It can take a while to get new ones in, though, and now I've only got one,' [the franklin] says. 'Know what? I'm not really good for going up there today, so why don't you go check the bulb and see about changing it?'".
Response of Franklin when asked about the green fuse:
	Say "'Think that's the right kind for the elevator. There's an electrical box out back. Of course, with the ledge and the drop and all that, I can't go out there'".
Response of Franklin when asked about the red fuse:
	Say "'Never figured out what the red ones go in. Probably something up high where I'm not likely to look.'".
Response of Franklin when asked about Franklin:
	Say "'I'm Franklin. Not anything Franklin or Franklin anything, though. Just Franklin.'";
	Introduce Franklin.
Response of Franklin when asked about the lighthouse:
	Say "'Lightning did a number on the old girl,' [the franklin] says. 'No idea why. It's not like lightning doesn't strike all the time. I'm trying to get her going again. The light needs to spin. And shine, too. Shining is also important. It'd be easier if I went up on top, of course.'".
Response of Franklin when asked about the elevator:
	Say "'The elevator is the easy way to the top of the lighthouse. The stairs are the hard way, and the scary way. Being way up there is terrifying enough. It's a pretty long fall. But falling all that way and hitting every step on the way down? I'd rather not. Besides, could you imagine carrying the bulbs up the stairs?' [the franklin] says.".
Response of Franklin when asked about the iron key:
	Say "'That's for the elevator,' [the franklin] says. 'Don't lose it.'".
Response of Franklin when asked about the socket:
	Say "'It's kind of obvious, isn't it? It's a socket for bulbs. It spins and it lights up.'".
Response of Franklin when asked about the electrical box:
	Say "[the franklin] says, 'It probably just needs a new fuse. If it wasn't out on that narrow ledge I would have replaced it already.'";
	If Franklin encloses the maintenance key:
		Now the player holds the maintenance key;
		Say "[The franklin] hands you a key.".
Response of Franklin when asked about the control panel:
	Say "'It's really pretty simple once you understand how it works,' [the franklin] says. 'I had a little cheat sheet... but I don't know where it's gone too. Personally, I've always wanted to put the controls down here so I can work them without holding on for dear life.'".
Response of Franklin when asked about the power junction:
	Say "'What? On the ceiling at the top of the lighthouse? If I climbed all the way up there, why would I want to climb even higher to look at that?'".
Response of Franklin when asked about the burnt out bulb:
	Say "'If it's black inside like you say,' [the franklin] says, 'then it needs to be replaced.'".

Chapter - Ilana

Ilana is a hidden privately-named woman. The real name is "Ilana". The printed name is "frumpy nurse". The description is "[The Ilana] has seen better days. She's wearing scrubs for no logical reason except, possibly, to advertise the fact that she is a nurse. She must not be a very good one, if she's stuck out here on this horrible island.".
Understand "nurse", "frumpy", "frumpy nurse" as Ilana.
Understand "ilana" as Ilana when Ilana is introduced.
Ilana is not proper-named.

Rule for writing a paragraph about Ilana:
	Say "[The Ilana] mucks about in the sink.".
	
Ilana holds the apple key.

To say not Ilana:
	Say "[one of]Ilena[or]Alana[or]Ilene[or]Ilania[or]Alen[then purely at random]".
	
The ask-suggestions of Ilana are { self-suggestion, subject-grandmother, Catherine, Alabaster, ghosts }.

Response of Ilana when asked about Ilana:
	Say "'It's not easy, nursing, you know,' [the Ilana] says. 'It's rather thankless, actually. I get to be yelled at by an old woman all day, and then someday she will die and I am expected to be sad. She never even uses my right name. It's Ilana.'";
	Introduce Ilana;
	Now Catherine is familiar.
Response of Ilana when asked about subject-grandmother:
	Say "'Your grandmother? I have no idea who that is, of course.'".
Response of Ilana when asked about Catherine:
	If Catherine is introduced:
		Say "'I don't think it's very likely that Catherine is your grandmother,' [the Ilana] says. 'I'd think she would have mentioned it. When she's coherent, all she talks about are the [link]ghosts[as]ask nurse about ghosts[end link].";
		Now the ghosts are familiar;
	Otherwise:
		If Catherine is asleep:
			Say "'You don't want to go anywhere near that old witch,' [the Ilana] says. 'She's sleeping upstairs. Don't wake her up.'.";
		Otherwise:
			Say "'Fantastic. You woke her up, you go see what she wants.'";
			If Ilana encloses the apple key:
				Say "[The Ilana] hands you a small house key.";
				Now the player holds the apple key.
Response of Ilana when asked about Alabaster:
	Say "[The Ilana] humphs. 'I've told that man dozens of times that this isn't an inn any more, but he won't leave. Not until he finds his precious [link]ghosts[as]ask nurse about ghosts[end link]'.";
	Now the ghosts are familiar.
Response of Ilana when asked about the ghosts:
	Say "'There are four of them, but I've never seen one,' [the Ilana] says. 'Not that I would want to. Some kind of fisherman, and the girl. I'm sure Catherine will talk your ear off about them.'".
		
Book - Scenes

Chapter - Special Action Scenes

A scene can be blocking or non-blocking. A scene is usually non-blocking.
The blocking scene special action rules is a rulebook.

A blocking scene special action rule (this is the default blocking scene rule):
	Now the relevant action is the action of the person asked fake-actioning;
	Rule fails.
	
Chapter - Outset

Outset is a scene. Outset begins when play begins. Outset ends when the player is in the ferry.
Rule for printing the banner text when Outset is happening: do nothing.

When outset begins:
	Say "It is a wet, disgusting day in the middle of April. You are just about sick of the rain. You're just about sick of everything. They keep telling you, when you turn sixteen you can do what you like and live where you like. But you aren't sixteen, and until then you've got to do what they say. 'They' are a procession of incompetent adults, colloquially called 'social workers,' culminating in the buffoon that has brought you here. Mr. Henrico.[paragraph break]Apparently, he is the idiotic little man who tracked down your grandmother. The same grandmother who never visited you, or sent you anything, or even spoke to you. And he's decided you're going to go live with her on some horrible little island. You are so excited. You have just spent the last four hours listening to him talk, and it doesn't look like he's done.[paragraph break]Press any key...";
	Wait for any key;
	Say "[line break]'Are you ready to go?' Mr Henrico asks. 'Or is there anything else you want to talk about first?'";
	Set the current weather to raining.
	
	

Chapter - Opening boat ride

Opening boat ride is a scene. Opening boat ride begins when the player is in the ferry. Opening boat ride ends when the ferry is in the jetty.
[Opening-hint is a hint with description "You can engage the ferry captain in conversation. Just [command]ask man something[normal].".]

When opening boat ride begins:
	If testing-the-end-flag is false:
		Say "As the ferry powers up to pull away from the dock, [the shoo] hops from the boardwalk to the ferry. Apparently, the bird is too lazy to fly to the island itself.";
		Now Shoo is in the ferry;
		Now the ferry is in the sea;
		Say "'First time on the island, isn't it?' [the spider] asks. 'Well, I hope you like it. It's not a terribly big island and hardly anyone visits anymore. Yep, because the only way there is a ride in my ferry!'[paragraph break][The Spider] asks, 'So lass, you got any questions before we get there? Now's your chance to ask.'";
		The storm breaks in 5 turns from now;
		Start a conversation with Spider.
	
At the time when the storm breaks:
	Say "The wind picks up and suddenly, rather than a moderate chop, waves smash against the ferry from all sides. Lightning flashes from the sky and rain pours from the heaven in torrents between the rolling thunder.[paragraph break]";
	Say "'Going to be a bit of chop,' [the spider] says. Your stomach does not like this news at all.";
	Set the current weather to Tempest;
	Now the sea is rough;
	The lightning strikes in 3 turns from now.
	
At the time when the lightning strikes:
	Say "A bolt of lightning stabs out of the sky and strikes the lighthouse.  For a moment, while the bolt is etched across your vision, nothing happens, then the sound comes rolling over the boat and makes everything shake. Behind the thunder comes another sound, an electrical popping, and the lighthouse seems to glow at the base. At it's top, the light vanishes.[paragraph break]Your stomach has had it with the waves. You rush to the railing as your lunch rushes up your throat, and then you don't do much of interest besides puke your guts out for the rest of the trip.[paragraph break][If hyperlinks are currently disabled]Press any key..[end if]";
	If hyperlinks are currently disabled:
		Wait for any key;
	Say "[paragraph break][banner text][paragraph break][if hyperlinks are currently disabled]Press any key...[end if][paragraph break]";
	If hyperlinks are currently disabled:
		Wait for any key;
	Now the ferry is in the jetty;
	Now Spider is in the jetty;
	Now the player is in the jetty;
	[Now Shoo is in the square;]
	Say "'You all right lass?' [the spider] asks. 'Had a touch of sea sickness, you did. We're here, anyway. Best damn island this side of Delmarva.'";
	Set the current weather to Sunny;
	Now Elizabeth is in the square;
	Now the ferry is distant;
	If the player does not enclose the mackerel, now the mackerel is in the aquarium; [avoid making the mackerel un-catchable.]
	Stop the pocket watch;
	Abort fishing;
	If the fishing pole is in the boardwalk or the boardwalk-poles are in the boardwalk, now the fishing pole is in the shack; [Rescue the fishing pole from a player who left it behind]
	Now the current interlocutor is nothing;
	Suppress listing topics. [In case the player was speaking with Elizabeth when the scene ended]
	
Chapter - Blocking scenes
	
Section - Shoo steals the pocket watch

Shoo steals the watch is a blocking scene. 
Shoo steals the watch begins when the player is in the square for the first time.
Shoo steals the watch ends when Shoo is in the narrow ledge.

To dump inventory in (place - a room):
	Repeat with item running through everything held by the player:
		If item is not the skirt:
			If item is not the shirt:
				Now item is in place.

When Shoo steals the watch begins:
	Say "[The Shoo] barrels into you and knocks you flat on your back. You drop everything you're holding.";
	Dump inventory in the location of the player;
	Say "[The shoo] stands on your chest and peers at you over its immense beak.";
	Now Shoo is in the square.
	[Shoo flies off in two turns from now.]
	
To say shoo-failure:
	Say "[one of]You struggle against [the shoo] but can't budge the immense bird.[or][The shoo] standing on your chest is too distracting to think about anything else.[or]That's it, you're going to [link]hit that bird[as]hit bird[end link]![purely at random]";
	
Instead of doing anything other than hitting or solving or examining during Shoo steals the watch:
	Say "[shoo-failure]".
	
Check hitting during Shoo steals the watch:
	If the noun is shoo, continue the action;
	Otherwise say "[shoo-failure]" instead.
		
Check examining during Shoo steals the watch:
	If the noun is Shoo, continue the action;
	Otherwise say "[shoo-failure]" instead.
			
Instead of hitting shoo during Shoo steals the watch:
	If the location of the old beeper is nothing or the location of the old beeper is the boardwalk:
		Say "You give the pelican a very satisfying smack. [The shoo] squawks and then pukes up a half eaten [link]fish head[as]x fish head[end link]. Thankfully, she misses you. An [old beeper] plops out amongst the fish. Then something else catches [the shoo]'s eye. She snatches [the pocket watch], swallows it, and vanishes into the sky.";
		Now the old beeper is in the square;
		Now the fish-head is in the square;
	Otherwise:
		Say "You give the pelican a very satisfying smack. [The shoo] squawks and flops off of you. Then something else catches [the shoo]'s eye. She snatches [the pocket watch], swallows it, and vanishes into the sky.";
	Now Shoo is in the narrow ledge;
	Remove the pocket watch from play;
	Now Shoo is watching;
	Award 4 points with message "4 points for hitting that bird right in the face";
	Stop the action.
	
Blocking scene special action when Shoo steals the watch is happening:
	Now relevant action is the action of the person asked hitting shoo;
	Rule succeeds.
	
Action fruitful rule for the greet action when Shoo steals the watch is happening:
	Rule fails.
	

	
Section - Encountering Alabaster

Encountering Alabaster is a blocking scene. Encountering Alabaster begins when the player is in the sitting room for the second time. Encountering Alabaster ends when the projector is switched off.

Sitting room counter is a number that varies. Sitting room counter is 0.
First before going (This is the detect sitting room entrance rule):
	If the room gone to is the sitting room:
		Increase sitting room counter by 1;
		If sitting room counter is 2:
			Now the projector is in the sitting room;
			Activate the projector;
			Now Alabaster is familiar;
	Continue the action.
	
[The detect sitting room entrance rule is listed before the implement porch-door rule in the before rulebook.]

Rule for writing a paragraph about Alabaster when Encountering Alabaster is happening:
	Say "[The Alabaster] is holding onto your arm quite tightly.".

When Encountering Alabaster begins:
	Say "'Amazing!' exclaims [the alabaster] 'It works! Do you see this?'[paragraph break][The alabaster] rushes over to you and drags you across the room by your arm. There is a portable projector sitting in the center of the room, and it seems to be what he's so excited about. The odd thing about it is that there isn't actually any image being projected anywhere. It's definitely a projector, though. It has a big spinning reel of film and it's clicking away and everything.[paragraph break][The alabaster] parks you in front of the projector to make sure you get a real good look. 'Amazing!' he says.";
	Start a conversation with Alabaster.
	
First Before going during Encountering Alabaster:
	Say "[The Alabaster] is holding on to your arm. It's starting to hurt.";
	Stop the action.
	
Check taking during Encountering Alabaster:
	If the noun is the projector, continue the action;
	Say "You can't reach that. Not with [The Alabaster] holding on to your arm." instead.
	
Before switching off the projector when Encountering Alabaster is happening:
	Award 4 points with message "4 points for escaping from the fat man";
	Continue the action.
	
Before hitting Alabaster with something when Encountering Alabaster is happening:
	Try hitting Alabaster.
	
Before hitting Alabaster when Encountering Alabaster is happening:
	Say "You take a swing at [the alabaster], but he must have seen it coming. You miss and hit the projector instead, which falls over.";
	Award 4 points with message "4 points for escaping from the fat man";
	Deactivate the projector;
	Try the player looking;
	Stop the action.
	
Blocking scene special action when Encountering Alabaster is happening:
	Now relevant action is the action of the person asked switching off the projector;
	Rule succeeds.

Section - Modifying locales for ghost cutscenes

The store room is a room.

To empty (place - a room):
	Repeat with item running through everything in place:
		If item is not scenery and item is not a backdrop:
			If item is not an excavation lamp and item is not the ancient chest:
				Now item is in the store room.

To restore (place - a room):
	Repeat with item running through everything in the store room:
		Now item is in place.
		
Section - Presto - Not For Release
			
Prestoing is an action applying to nothing.
Understand "presto" as prestoing.
Carry out prestoing:
	Now the mausoleum is not locked;
	Now the player is in the graveyard.
	
	


Section - Putting Franklin to rest

Putting Franklin to rest is a blocking scene.
Putting Franklin to rest begins when (the lighthouse is operational and the player is in the machinery room and the machinery room is ghostly). 
Putting Franklin to rest ends when Franklin is at peace.

Blocking scene special action when Putting Franklin to rest is happening:
	Now relevant action is the action of the person asked climbing the cutscene-ladder;
	Rule succeeds.

When Putting Franklin to rest begins:
	Start the franklin memory.	
		
To start the franklin memory:
	Say "'It's lit! It's lit!' [the Franklin] shouts. He grabs your hands and spins you in a little circle. 'I can't believe you did it. This is amazing. You should stay here forever, I'll teach you everything about the lighthouse, and then I wouldn't have to go up there again.'[paragraph break]'But you can't, can you? It's obvious I can't stay here either. I can't stand to be way up there, even when it's really important. Like the night of that storm.'[paragraph break]Press any key...";
	Wait for any key;
	Set the current weather to tempest;
	Empty the lighthouse balcony;
	Now the cutscene-ladder is in the lighthouse balcony;
	Reveal the lighthouse balcony decor ladder;
	Now Franklin is in the lighthouse balcony;
	Now the player is Franklin;
	Try looking;
	Say "Lightning flashes in the distance. Each roll of thunder seems like it will shake you from the lighthouse, send you falling forever. It's not heights that get you. The depths are what really do you in. You could stare up at the lighthouse all day with no problems at all. The wind tugs at your grease stained overalls. You clutch at the thin metal railing that separates you from a long fall onto crashing surf and rocks. Your knees wobble and your hands shake, but you push yourself onward.".
	
To end the franklin memory:
	Say "You shut your eyes and grit your teeth. Whoever heard of a lighthouse operator afraid of heights? One foot after the other, you climb the ladder onto the roof of the lighthouse. The braided ground wire whips back and forth before you. You grab it, and crawl toward the base of the lightning rod.[paragraph break]Just as you reach the rod, lightning stabs out of the sky. The entire lightning rod glows white in the split second before it blinds you entirely. There is a massive roar and you are thrown backwards. You are sliding, and then falling. For a brief moment you think the ground wire might save you, but it pulls free from the side of the lighthouse with a series of pops. At least you can't see the surf rushing toward you.[paragraph break]Press any key.";
	Wait for any key;
	Now the player is yourself;
	Now franklin is at peace;
	Restore the lighthouse balcony;
	Remove the cutscene-ladder from play;
	Remove Franklin from play;
	If the ladder is held by the player or the ladder is not in the lighthouse balcony:
		Hide the lighthouse balcony decor ladder;
	Now the player is in the ocean cave;
	Award 10 points with message "10 points for helping Franklin overcome his fear of heights".
		
Every turn during Putting Franklin to rest:
	Say "[one of]You clutch at the thin metal railing. It is slick in your hands.[or]The braided metal coord from the lightning rod whips in the wind of the storm.[or]If lightning strikes the lighthouse before you can re-ground the lightning rod, you have no idea how much damage it would do.[cycling]".
	
The cutscene-ladder is an enterable supporter with printed name "ladder". 
Understand "ladder" as the cutscene-ladder.

Instead of entering the cutscene-ladder:
	Try going up.
	
Instead of climbing the cutscene-ladder:
	Try going up.
	
The up-attempts is a number that varies. Up-attempts is 0.

Before going during Putting Franklin to rest:
	If the room gone to is the lighthouse apex:
		Say "You're here for a reason. You can't give up now.";
	Otherwise:
		Increase up-attempts by 1;
		If up-attempts is 1, say "You put both shaking hands on the ladder. You glance behind yourself and catch a glimps of the surf crashing far below, and then you are clutching the railing again.";
		If up-attempts is 2, say "Al right. You're going to do it this time. You haven't got a choice. How many lives are depending on you right now? You clutch the ladder. You place one foot on the bottom rung. You turn and wretch over the railing instead of climbing.";
		If up-attempts is 3, end the franklin memory;
	Stop the action.	

Instead of examining the balcony windows during Putting Franklin to rest:
	Say "Through the rain streaked windows you can just make out the control room with it's comforting lack of long drops, and a man in a dark hood.".
	
After deciding the scope of the player during Putting Franklin to rest:
	Place Death in scope.
	
Section - Putting Spider to rest

Putting Spider to rest is a blocking scene.
Putting Spider to rest begins when the player is Spider.
Putting Spider to rest ends when Spider is at peace.

Spider-rest-state is a number that varies. Spider-rest-state is 0.

Blocking scene special action when Putting Spider to rest is happening:
	If Spider-rest-state is 0:
		Now relevant action is the action of the person asked opening the ancient chest;
	Otherwise:
		Now relevant action is the action of the person asked going south;
	Rule succeeds.

To start the Spider memory:
	Say "'A coin? Is this?' [the spider] holds up the coin to get a good look at it. Then he bites it. 'Look at that!' he exclaims. 'No dents! It's real gold! You found it! How much is there? .. Just this? Well I'll be damned.'[paragraph break]'I found the chest, you know,' [the spider] says. 'Why didn't I ever open it..?'[paragraph break]Press any key...";
	Wait for any key;
	Empty the treasure chamber;
	Now Spider is in the treasure chamber;
	Now every excavation lamp is lit; [For testing: In ordinary play, they must have been lit by now]
	Change the south exit of the treasure chamber to the colonnade chamber;
	Now the ancient chest is locked;
	Now the player is Spider;
	Try looking;
	
	
To end the Spider memory:
	Wait for any key;
	Now the player is yourself;
	Now Spider is at peace;
	Restore the treasure chamber;
	Remove Spider from play;
	Now the player is in the jetty;
	Award 10 points with message "10 points for finding the Captain's treasure".
		
Before going during Putting Spider to rest:
	If Spider-rest-state is 0:
		Say "You've come this far, you aren't going to leave without opening that chest.";
	Otherwise:
		Say "As you approach the exit from this tiny chamber, the earth begins to shake. You rush forward. Bits of stone and a lot of dust fall from the ceiling, and then, with a great crash, the ceiling gives way. Stones piles up across your path. You are immediately plunged into darkness.[paragraph break]Press any key...";
		End the Spider memory;
	Stop the action.	
	
Before unlocking keylessly the ancient chest during Putting Spider to rest:
	If Spider-rest-state is 0:
		Say "You pull at the lid of the chest and.. no good, it's locked. Where did you put that ancient key? [run paragraph on]";
	Say "You've forgotten it! The key, that is. You'll have to go all the way back to your shack to get it.";
	Now Spider-rest-state is 1;
	Stop the action.
	
Section - Putting Elizabeth to rest

Putting Elizabeth to rest is a blocking scene.
Putting Elizabeth to rest begins when the player is Elizabeth.
Putting Elizabeth to rest ends when Elizabeth is at peace.
Elizabeth can be guilty or assuaged. Elizabeth is guilty.

Blocking scene special action when Putting Elizabeth to rest is happening:
	Now relevant action is the action of the person asked hitting the little girl;
	Rule succeeds.
	
The drowning-sea is a room with printed name "In the sea". The description is "Waves crash and smash all around you.[if ferry-state is less than 3] The ferry is thrown about by the waves nearby.[end if]".

The little girl is a woman with printed name "little girl". The little girl is not proper-named. The description is "A girl, somewhere between ten and thirteen, with her hair plastered down across her face and her wild eyes. You only see her face in flashes as the waves roll around you. She appears, sputters out a moutful of water, and vanishes again as another wave sweeps over her. She is grabbing at you in a panicked mania.";

The preserver is a thing with printed name "life saver". Understand "life", "saver", "life saver" as the preserver. The description of the preserver is "A floating ring painted red and white.";

Ferry-state is a number that varies. Ferry-state is 0.
The decor ferry is some privately-named scenery in the drowning-sea. The decor ferry can be vanished. The decor ferry is not vanished. The description of the decor ferry is "[if ferry-state is at least 4]The ferry has vanished into the waves. You can't catch even a glimps of it.[otherwise]The ferry smashes up and down in the waves. On the deck you can see a man in a dark hood.[end if]".
Understand "ferry", "boat", "fery" as the decor ferry.
After deciding the scope of the player during Putting Elizabeth to Rest:
	If ferry-state is less than 4:
		Place Death in scope.
		
Every turn during Putting Elizabeth to Rest:
	Increase ferry-state by 1;
	If ferry-state is 4:
		Say "The ferry vanishes into the waves.".

To start the Elizabeth memory:
	Say "'That's very nice but I don't think I'm your type,' [the Elizabeth] says. 'Oh, is that Peridot? That's my birthstone..'[paragraph break][The Elizabeth] takes the ring to get a better look.[paragraph break]'This is why Gerald insisted we come here today, isn't it? He was going to.. but the ferry..'[paragraph break]Press any key...";
	Wait for any key;
	Now Elizabeth is in the drowning-sea;
	Now the little girl is in the drowning-sea;
	Now the preserver is in the drowning-sea;
	Now the player is Elizabeth;
	Say "You are sitting on the ferry, and then the crashing sea is all about you. You are in the water, but thankfully you can swim. The girl from the ferry breaks the surface nearby. She was perhaps thrown from the ferry by the same wave that took you. She breaks the surface flailing and gasping and smacking about at the water, and the first thing she spots is you. She grabs at you, frantic to pull herself out of the water.";
	Try looking.	
	
To end the Elizabeth memory:
	Wait for any key;
	Now the player is yourself;
	Now Elizabeth is at peace;
	Remove Elizabeth from play;
	Remove the little girl from play;
	Now the player is in the beach;
	If Elizabeth is assuaged:
		Award 10 points with message "10 points for assuaging Elizabeth's guilt";
	Otherwise:
		Award 10 points with message "10 points for saving yourself from a child".


	
Before doing anything during Putting Elizabeth to Rest:
	If solving, continue the action;
	If swimming, continue the action;
	If looking, continue the action;
	If examining, continue the action;
	If taking inventory, continue the action;
	If taking, continue the action;
	If hitting or hitting something with, continue the action;
	If giving something to or saying hello to, continue the action;
	Say "You're slipping under the water. There's nothing you can do now but [link]swim[end link] as hard as you can!";
	Stop the action;
	
Every turn when Putting Elizabeth to rest is happening:
	Say "The girl clutches at you frantically. If you don't do something, you'll both drown.".
	
Swimming is an action applying to nothing. 
Understand "swim" as swimming.

Before swimming:
	If the location of the player is not the drowning-sea:
		Say "You can't swim.";
		Stop the action;
	If the player is Elizabeth:
		Say "You aren't going to make it far with that girl clutching at you. If she doesn't let go, you'll both drown.";
	Otherwise:
		Say "You never learned how to swim. Seems, in hindsight, it would have been a useful skill.";
	Stop the action.
	
Response of the little girl when given the preserver:
	Now Elizabeth is assuaged;
	Say "The girl clutches at the life saver and, mercifully, lets you go. You've done all you can for her, you have to worry about yourself. You swim toward shore.. at least. You swim the direction you think is shore. You can't see a thing but the waves.[paragraph break]Press any key...";
	Wait for any key;
	Say "You swim until your legs will move no more, and then you swim some more. It does no good. You never even see the island. At least, you think as you watch the day light fade overhead, you gave that girl a fighting chance.[paragraph break]Press any key...";
	End the Elizabeth memory.
	
Before hitting the little girl with something:
	Try hitting the little girl instead.
	
Before hitting the little girl:
	Now Elizabeth is guilty;
	Say "You smack the girl as hard as you can, given the conditions. She lets you go, and you immediately use lose sight of her between the waves. It does no good for you both to drown, you remind yourself.  You swim toward shore.. at least. You swim the direction you think is shore. You can't see a thing but the waves.[paragraph break]Press any key...";
	Wait for any key;
	Say "You swim until your legs will move no more, and then you swim some more. It does no good. You never even see the island. Your last thought, as you watch the day light slowly engulfed by the water above you, is about that little girl...[paragraph break]Press any key...";
	End the Elizabeth memory.
	

Chapter - Miscellaneous Scenes

Section - Granting hints

The hints turn counter is a number that varies. The hints turn counter is 0.
Granting Hints is a scene. Granting Hints begins when the hints turn counter is 20. Granting Hints ends when the location of the old beeper is not nothing.
Every turn during outset:
	Increase the hints turn counter by 1.

When Granting Hints begins:
	Say "[The shoo] squawks, and then chucks a half eaten [link]fish head[as]x fish head[end link] onto the boardwalk. Out with the fish comes an [old beeper].";
	Now the old beeper is in the boardwalk;
	Now the fish-head is in the boardwalk.
	
Section - Active Death

Active Death is a scene. Active Death begins when Spider is at peace and Franklin is at peace and Elizabeth is at peace. Active Death ends when the player is in the mausoleum.

When Active Death begins:
	Now Death is in the bay room;
	Now the ask-suggestions of Death are { yourself, self-suggestion, Spider, Franklin, Elizabeth };
	Now Death is piqued.
	
To insert (suggestions - a list of objects) into the suggestions of (bob - a person):
	Repeat with sug running through suggestions:
		Add sug to the ask-suggestions of bob, if absent.
	
Every turn during Active Death:
	If the location of the player is the bay room and the location of death is the bay room:
		If Death is not the current interlocutor and Catherine is not the current interlocutor:
			Say "[The Death] turns his quiet gaze toward you. 'It has been long enough,' he says.";
			Start a conversation with Death;
	Otherwise if the location of the player is the upstairs hallway and the location of Death is the upstairs hallway:
		Try Death going down;
	Otherwise if the location of the player is the sitting room and the location of Death is the sitting room:
		Try Death going south;
	Otherwise if the location of the player is the yard and the location of Death is the yard:
		Try Death going south;
	Otherwise if the location of the player is the square and the location of Death is the square:
		Try Death going south;
	Otherwise if the location of the player is the chapel and the location of Death is the chapel:
		If the location of Brisbane is not the chapel:
			Now Brisbane is in the chapel;
			If the aspergillum is enclosed by the chapel office:
				Now Brisbane holds the aspergillum;
			Now Brisbane holds the crystal glass;
			If Brisbane holds the aspergillum:
				Say "[The Brisbane] barges out of the tiny chapel waving about his aspergillum. He clutches his amber drink in his other hand. Fat drops cascade from both.";
				Now Brisbane is bs-B;
			Otherwise:
				Say "[The Brisbane] barges out of the tiny chapel waving about his amber drink. Fat drops cascade from it.";
				Now Brisbane is bs-C;
			Say "'It's too soon,' [the brisbane] says. 'I won't let you go.'";
			Insert { yourself, self-suggestion, Death, the aspergillum, the iron gate } into the suggestions of Brisbane;
			Say "[The death] goes south. He passes through the gate as if it weren't there.";
			Now Death is in the graveyard.
		
Response of Death when asked about Death during Active Death:
	If the location of Death is the bay room:
		Say "'You should have figured it out by now,' [the death] says. 'Come with me.'";
		Suppress listing topics;
		Try Death going south;
	Otherwise if Death is anonymous:
		Say "'If you insist, child.' [The death] pulls back his hood to reveal a white skull with a grinning, lipless mouth.";
		Introduce Death;
		Award 4 points with message "4 points for the grinning skull";
	Otherwise:
		Say "'Enter the mausoleum,' [the death] says. 'All your answers are inside.'".
Response of Death when asked about Franklin during Active Death:
	Say "'He was in the navy once. They discharged him due to crippling phobia, so he joined the coast guard. A secretary misplaced his file.'".
Response of Death when asked about Elizabeth during Active Death:
	If Elizabeth is guilty:
		Say "'Things may have gone different for Elizabeth if her last act was not one of selfishness. Or perhaps not.'";
	Otherwise:
		Say "'She surprised me. I had expected her to keep the life preserver for herself. In the end, though, it would have done her no good.'".
Response of Death when asked about Spider during Active Death:
	Say "'He became so obsessed with his treasure. It consumed him utterly. He was more sensible about it before his ferry sank. Guilt made it into more than just a harmless hobby.'".
Response of Death when asked about yourself during Active Death:
	If the location of the player is the bay room:
		Say "'You've done everything I expected. It's time to go.'";
		Suppress listing topics;
		Try Death going south;
	Otherwise:
		Say "'Enter the mausoleum. All you answers are inside.'".
	
	
Section - Ending for Intro Comp Entry

[
Intro Comp Ending is a scene. Intro Comp Ending begins when Shoo steals the watch ends.

When Intro Comp Ending begins:
	Say "Thanks for playing the beginning of Akkoteaque! There's lots more to do on the island. I agonized for a while, but eventually decided I'd rather cut the game short then let players loose on a largely unfinished island. Here's what you can expect from the finished game...[paragraph break]-Explore the lighthouse, the Lighthouse Inn, and the rest of the island.. including a spooky graveyard![line break]-Be terrorized by a crazed pelican![line break]-Meet lots of interesting characters, like Alabaster, the plaster salesman and amateur paranormal investigator![line break]-Dig up a buried treasure![line break]-Find out why your grandmother is so horrible![line break]-Catch fish![line break]-Solve lots of puzzles![line break]-Find dozens of ciphered messages and probably never manage to decode them![paragraph break]I hope you enjoyed Akkoteaque. I'm always looking for more testers.[paragraph break]I'm going to let you back into the world now. Why don't you try fishing? The fish head makes excellent bait.";
	
Before going during Intro Comp Ending:
	If the room gone from is the square:
		If the room gone to is the narrow stair:
			Continue the action;
		Say "Sorry, the rest of the island isn't ready yet. [one of]Why don't you talk to [the Elizabeth]?[or][The Spider]is just to the west.[or]You could try fishing.[or]There's something you could find on the pier.[or][The Spider] has something that belongs to [the elizabeth].[purely at random]";
		Stop the action. 
]
		
Section - The End


The Ending is a scene. The Ending begins when the player is in the mausoleum. 

Testing-the-end-flag is a truth-state that varies. Testing-the-end-flag is false.

When The Ending begins:
	Award 10 points with message "10 points for shutting yourself into darkness";
	Say "The mausoleum doors swing shut behind you.";
	Now the mausoleum is closed;
	Now the ferry is in the boardwalk;
	Now Spider is on the ferry;
	Now Elizabeth is on the ferry;
	Now Shoo is in the boardwalk;
	Now Shoo is done;
	Now the mausoleum is in the boardwalk;
	Now testing-the-end-flag is true;
	Dump inventory in the graveyard.

	
First response of Henrico during The Ending:
	Say "Mr. Henrico stares off at the ferry. He doesn't seem to notice you standing there.".
	
The Ending Ride is a scene. The Ending Ride begins when the player is in the ferry and The Ending is happening.
When The Ending Ride begins:
	Say "As the ferry powers up to pull away from the dock, [the shoo] hops on board.";	
	Now Shoo is in the ferry;
	Now the ferry is in the sea;
	Say "'First time on the island, isn't it?' [the spider] asks. 'Well, I.. hmm. I guess I best stick to driving the boat instead of chatting.'";
	The final storm breaks in 5 turns from now;
	[Now the ask-suggestions of spider are { the lighthouse, akkoteaque, elizabeth, death, shoo };]
	Start a conversation with Spider.
	
At the time when the final storm breaks:
	Say "The wind picks up and suddenly, rather than a moderate chop, waves smash against the ferry from all sides. Lightning flashes from the sky and rain pours from the heaven in torrents between the rolling thunder.[paragraph break]";
	Say "'Going to be a bit of a chop,' [the spider] says. That is something of an understatement.";
	Set the current weather to Tempest;
	Now the sea is rough;
	The final lightning strikes in 3 turns from now.
	
At the time when the final lightning strikes:
	Say "A bolt of lightning stabs out of the sky and strikes the lighthouse.  For a moment, while the bolt is etched across your vision, a flailing shape slides down past the smooth face of the lighthouse; and then the shape and the light vanish.[paragraph break]The boat pitches in the waves. You get just a glimps through the surf and rain of the side of the cargo ship looming up before you, and then the world is spinning and over end, and is suddenly very dark and wet.[paragraph break]You scramble for the surface and grab the first thing before you, which happens to be [the elizabeth].[paragraph break]";
	Suppress listing topics;
	Now Elizabeth is in the drowning-sea;
	Now the preserver is in the drowning-sea;
	Now the player is in the drowning-sea;
	Set the current weather to sunny.
	
The ending-sea is a scene. The ending-sea begins when the player is in the drowning-sea and The Ending is happening.

Before doing anything during the ending-sea:
	If Elizabeth is in the drowning-sea:
		Say "You're holding onto [the elizabeth] for dear life. You can't do anything else.[paragraph break]";
		If Elizabeth is assuaged:
			Say "[The Elizabeth] pushes the life preserver into your hands. She seems grateful when you let go of her, but after the barest of moments she's vanished into the waves.";
		Otherwise:
			Say "[The Elizabeth] strikes you across the face. You're so shocked you let go of her entirely. Thankfully, as you flail about, your arm smacks a life preserver.";
		Now the player holds the preserver;
		Now Elizabeth is in the square; [Just get rid of her.]
		Now ferry-state is 0;
		Stop the action;
	Continue the action;
	
[See Elizabeth section for the paragraph about Elizabeth]
Rule for writing a paragraph about Elizabeth when the player is in the drowning-sea:
	Say "You are holding onto [the elizabeth]. She's all that's keeping you afloat.".
	
Before dropping the preserver during the ending-sea:
	Say "That's all that's keeping you afloat!";
	Stop the action.
	
Instead of going when in the drowning-sea:
	Try swimming.
	
After deciding the scope of the player during ending-sea:
	If ferry-state is less than 4:
		Place Death in scope.
		
Every turn during ending-sea:
	Increase ferry-state by 1;
	If ferry-state is 4:
		Say "The ferry vanishes into the waves.[paragraph break]";
		Say "[The Shoo] swoops down over the waves lands next to you with the slightest of splashes. The waves have calmed down and the sea has become strangly calm.[paragraph break]'Squack!' says [the shoo].";
		Now Shoo is in the drowning-sea;
		Now the description of the drowning-sea is "The sea is eerily calm. It's a perfect mirror, reflecting a bright sunny sky.";
	If ferry-state is 8:
		Say "The ferry rumbles up beside you, barely churning the water. [The Spider] lets a ladder down over the side.";		
		Now the ferry is in the drowning-sea;
		Reveal the ending-decor-ladder;
		Now Spider is on the ferry;
		Now Elizabeth is on the ferry;
		Now Catherine is on the ferry;
		Now Franklin is on the ferry;
		Now Death is on the ferry.
		
The ending-decor-ladder is hidden privately-named scenery in the drowning-sea.
Understand "ladder" as the ending-decor-ladder.

Instead of going up in the drowning-sea:
	If the ending-decor-ladder is not hidden:
		Try climbing the ending-decor-ladder instead;
	Otherwise:
		Continue the action.
		
Instead of climbing the ending-decor-ladder:
	Say "You pull yourself onto the ferry. At the top, [The Elizabeth] takes your hand to help you over the edge. [The Spider] is at the controls, whistling some cheery tune, while [the Franklin] fiddles with something over by the engines.[paragraph break]In the middle of all of them, beaming and youthful again, is [the Catherine].";
	End the story finally.
	
Instead of entering the ferry during the ending-sea:
	Try climbing the ending-decor-ladder.
	
	
Book - Intelligent Hinting

The maximum score is 42.

[The Give-Me-A-Suggestion-Action is a global hyperlink action with printed name "get a suggestion" and command text "suggest".]

Section - The beeper

The old beeper is a thing with printed name "old beeper". The description of the old beeper is "This is a nasty old beeper. Nobody uses these things anymore, but somehow, it still works. It has a little LCD display which you could read.".
Understand "lcd", "display" as the old beeper.

Understand the command "read" as something new.
Reading is an action applying to one thing.
Understand "read [something]" as reading.
Check reading something:
	Try examining the noun instead.

Instead of reading the old beeper:
	Say "The LCD reads '[run paragraph on][the beeper display in caps]'."
Instead of pushing the old beeper:
	Try examining the old beeper.

__beeper_display is some indexed text that varies.

To decide which text is the beeper display:
	Now relevant action is the suggested action;
	Now saved parent is nothing;
	If relevant action is the action of the person asked going down:
		If actually-down is false:
			If relevant-direction is a direction, now relevant action is the action of the person asked going relevant-direction;
			Otherwise now relevant action is the action of the person asked fake-actioning;
	If relevant action is the action of the person asked fake-actioning:
		Now __beeper_display is "I DONT KNOW IM STUCK TOO";
	Otherwise:
		Now printing suggestion is true;
		Now __beeper_display is "try [relevant action]";
		Now printing suggestion is false;
	Decide on "[__beeper_display]".
	
Section - Winning the game
	
Winning-The-Game requires Reaching-The-Island, Putting-Ghosts-To-Rest, Final-Resolution.

Section - Spin - Not For Release

Spinning is an action applying to nothing. Understand "spin" as spinning.
Spinning counter is a number that varies. Spinning counter is 0.

Carry out spinning:
	Now the spinning counter is 10.
		
Rule for reading a command when Spinning counter is greater than 0:
	Decrease the spinning counter by 1;
	If the spinning counter is 0:
		Say "Spin depleted.";
	Otherwise:
		If the player is in the mausoleum:
			Say "ALL PUZZLES SOLVED.";
			Now the spinning counter is 0;
		replace the player's command with "solve".
		
Infinite-spinning is an action applying to nothing. Understand "ispin" as infinite-spinning.

Carry out infinite-spinning:
	Now the spinning counter is 100.
	


Part - Reaching The Island

Reaching-The-Island is a puzzle. Reaching-The-Island requires Feeding-Shoo, Boarding-The-Boat and Waiting-For-The-Storm.

Feeding-Shoo is a task with venue the Boardwalk.
Requirements for Feeding-Shoo:
	Let mack be a random fish enclosed by the coil of rope;
	Do the action of giving mack to Shoo;
Definition: Feeding-Shoo is complete if Shoo is fed.
	
Boarding-The-Boat is a task.
Requirements for Boarding-The-Boat: Do the action of entering the ferry.
Definition: Boarding-The-Boat is complete if the player is in the ferry.
	
Waiting-For-The-Storm is a task with venue the sea.
Requirements for Waiting-For-The-Storm:
	Do the action of waiting.
Definition: Waiting-For-The-Storm is complete if the player is in the jetty.

Part - Miscelaneous Dependancies

Section - Visiting the sitting room

Visiting-The-Sitting-Room is a task with venue the sitting room. Visiting-The-Sitting-Room can be accomplished. Visiting-The-Sitting-Room is not accomplished.
After looking in the sitting room for the first time:
	Now the venue of Visiting-The-Sitting-Room is the kitchen;
	Continue the action.
After going when the room gone from is the sitting room:
	Now Visiting-The-Sitting-Room is accomplished;
	Continue the action.
Definition: Visiting-The-Sitting-Room is complete if Visiting-The-Sitting-Room is accomplished.

When play begins:
	Repeat with puzz running through every lively-required task:
		Add Visiting-The-Sitting-Room to dependancies of puzz, if absent.

Section - Befriending the ducks

Befriend-The-Ducks is a puzzle. Befriend-The-Ducks requires Feed-The-Ducks.

Feed-The-Ducks is a ghostly-required task with venue the square.
Requirements for Feed-The-Ducks:
	Do the action of giving the loaf of bread to the ducks.
Definition: Feed-The-Ducks is complete if the player is the duck feeder.

Bring-The-Ducks is a ghostly-required task. [Bring-The-Ducks requires Befriend-The-Ducks.]
The dependancies of Bring-The-Ducks are { Befriend-The-Ducks }.
Bring-The-Ducks has a room called the final-destination.
Definition: Bring-The-Ducks is complete if the venue of Bring-The-Ducks encloses the player and the venue of Bring-The-Ducks encloses the ducks.

Every turn:
	If the garden is shoo-friendly:
		Now the final-destination of Bring-The-Ducks is the garden;
	Otherwise:
		Now the final-destination of Bring-The-Ducks is the beach;
	Now the venue of Bring-The-Ducks is the location of the ducks;
	If Bring-The-Ducks is complete:
		Now the venue of Bring-The-Ducks is the final-destination of Bring-The-Ducks;
	Now the venue of Smack-Shoo-A is the final-destination of Bring-The-Ducks;
	Now the venue of Smack-Shoo-B is the final-destination of Bring-The-Ducks.

Section - Smacking Shoo

Smack-Shoo-A is a lively-required task.
The dependancies of Smack-Shoo-A are { Bring-The-Ducks }.
Requirements for Smack-Shoo-A:
	Do the action of hitting shoo.
Definition: Smack-Shoo-A is complete if shoo is charming or shoo is done.

Smack-Shoo-B is a lively-required task.
The dependancies of Smack-Shoo-B are { Bring-The-Ducks, Smack-Shoo-A }.
Requirements for Smack-Shoo-B:
	Do the action of hitting shoo.
Definition: Smack-Shoo-B is complete if shoo is done.

Section - Acquiring the pocket watch

Acquiring-The-Pocket-Watch is a puzzle. Acquiring-The-Pocket-Watch requires Smack-Shoo-A, Take-Pocket-Watch.

Take-Pocket-Watch is a reversible task.
Requirements for Take-Pocket-Watch:
	Do the action of taking the pocket watch.
Definition: Take-Pocket-Watch is complete if the player encloses the pocket watch.

Every turn: 
	Now the venue of Take-Pocket-Watch is the location of the pocket watch.
	
Section - Accessing the Bay Room

Accessing-The-Bay-Room is a puzzle. Accessing-The-Bay-Room requires Waking-Catherine, Acquiring-Apple-Key.

Waking-Catherine is a lively-required task with venue the upstairs hallway.
Requirements for Waking-Catherine:
	Do the action of hitting the tree door with the wrench.
Definition: Waking-Catherine is complete if Catherine is not asleep.

Acquiring-Apple-Key is a lively-required task with venue the kitchen.
Requirements for Acquiring-Apple-Key:
	Do the action of quizzing Ilana about Catherine.
Definition: Acquiring-Apple-Key is complete if Ilana does not enclose the apple key.

Section - Fixing the Elevator

Fixing-The-Elevator is a puzzle. Fixing-The-Elevator requires Getting-The-Wrench, Banishing-Shoo, Opening-The-Electrical-Box and Completing-The-Electrical-Box.

Getting-The-Wrench is a task.
Requirements for Getting-The-Wrench:
	Do the action of taking the wrench.
Definition: Getting-The-Wrench is complete if the player encloses the wrench.

Banishing-Shoo is a task with venue the narrow ledge.
Requirements for Banishing-Shoo:
	Do the action of hitting Shoo.
Definition: Banishing-Shoo is complete if Narrow-Ledge-Shoo-State is 1.

Opening-The-Electrical-Box is a task with venue electrical alcove.
Requirements for Opening-The-Electrical-Box:
	Do the action of hitting the electrical box with the wrench;
	Do the action of opening the electrical box.
Definition: Opening-The-Electrical-Box is complete if the electrical box is open.

Completing-The-Electrical-Box is a task with venue electrical alcove.
Requirements for Completing-The-Electrical-Box:
	Do the action of inserting the green fuse into the electrical box.
Definition: Completing-The-Electrical-Box is complete if the electrical box is complete.

Part - Putting Ghosts to Rest

Putting-Ghosts-To-Rest is a puzzle. Putting-Ghosts-To-Rest is not puzzle-sequential. Putting-Ghosts-To-Rest requires Laying-Franklin-To-Rest, Laying-Spider-To-Rest, Laying-Elizabeth-To-Rest.

Chapter - Laying Franklin To Rest

Laying-Franklin-To-Rest is a puzzle. Laying-Franklin-To-Rest requires Powering-The-Lighthouse-Controls, Replacing-The-Bulb, Activating-The-Lighthouse, Visiting-Franklin.

The dependancies of Laying-Franklin-To-Rest are { Fixing-The-Elevator }.

Section - Replacing the bulb

Replacing-The-Bulb is a puzzle. Replacing-The-Bulb requires Getting-The-Prybar, Opening-The-Crate, Transporting-The-Bulb-A, Transporting-The-Bulb-B, Removing-The-Old-Bulb, Inserting-The-New-Bulb.

Disabling-Spin is a reversible task with venue the lighthouse apex.
Requirements for Disabling-Spin:
	Do the action of setting the red knob to "X";
	Do the action of setting the green knob to "Y";
	Do the action of setting the blue knob to "Z";
	Do the action of pulling the lever.
Definition: Disabling-Spin is complete if the socket is not spinning or the spare bulb is in the socket.

Getting-The-Prybar is a task.
Requirements for Getting-The-Prybar:
	Do the action of taking the prybar.
Definition: Getting-The-Prybar is complete if the player encloses the prybar or the crate is open.

Opening-The-Crate is a task with venue the yard.
Requirements for Opening-The-Crate:
	Do the action of prying the crate with the prybar.
Definition: Opening-The-Crate is complete if the crate is open.

Transporting-The-Bulb-A is a reversible cart-required task with venue the machinery room.
Requirements for Transporting-The-Bulb-A:
	Do the action of putting the spare bulb on the cart.
Definition: Transporting-The-Bulb-A is complete if the spare bulb is on the cart or the spare bulb is enclosed by the lighthouse apex.

Transporting-The-Bulb-B is a reversible cart-required task with venue the lighthouse apex.
Definition: Transporting-The-Bulb-B is complete if the spare bulb is enclosed by the lighthouse apex.

Every turn:
	Now the venue of Transporting-The-Bulb-A is the location of the spare bulb;
	Now the venue of Opening-The-Crate is the location of the crate;
	Now the venue of Getting-The-Prybar is the location of the prybar.

Removing-The-Old-Bulb is a reversible task with venue the lighthouse apex.
The dependancies of Removing-The-Old-Bulb are { Disabling-Spin }.
Requirements for Removing-The-Old-Bulb:
	Do the action of taking the burnt out bulb.
Definition: Removing-The-Old-Bulb is complete if the burnt out bulb is not in the socket.

Inserting-The-New-Bulb is a reversible task with venue the lighthouse apex.
The dependancies of Inserting-The-New-Bulb are { Disabling-Spin }.
Requirements for Inserting-The-New-Bulb:
	Do the action of inserting the spare bulb into the socket.
Definition: Inserting-The-New-Bulb is complete if the spare bulb is in the socket.

Section - Powering the controls

Powering-The-Lighthouse-Controls is a puzzle. Powering-The-Lighthouse-Controls requires Acquire-Red-Fuse, Climbing-The-Ladder-In-Lighthouse-Apex, Removing-Spent-Fuse, Placing-Red-Fuse.

Acquire-Red-Fuse is a reversible task.
Requirements for Acquire-Red-Fuse:
	Do the action of taking the red fuse.
Definition: Acquire-Red-Fuse is complete if the player encloses the red fuse or the red fuse is in the power junction.

Climbing-The-Ladder-In-Lighthouse-Apex is a reversible task with venue the lighthouse apex.
Requirements for Climbing-The-Ladder-In-Lighthouse-Apex:
	Do the action of climbing the ladder.
Definition: Climbing-The-Ladder-In-Lighthouse-Apex is complete if the player is on the ladder or the red fuse is in the power junction.

Removing-Spent-Fuse is a reversible task with venue the lighthouse apex. 
Requirements for Removing-Spent-Fuse:
	Do the action of taking the spent fuse.
Definition: Removing-Spent-Fuse is complete if the spent fuse is not in the power junction.

Placing-Red-Fuse is a reversible task with venue the lighthouse apex.
Requirements for Placing-Red-Fuse:
	Do the action of inserting the red fuse into the power junction.
Definition: Placing-Red-Fuse is complete if the red fuse is in the power junction.


Section - Activating the lighthouse

Activating-The-Lighthouse is a puzzle. Activating-The-Lighthouse requires Activating-Shine, Activating-Spin.

Activating-Shine is a reversible task with venue the lighthouse apex.
Requirements for Activating-Shine:
	Do the action of setting the red knob to "X";
	Do the action of setting the green knob to "Z";
	Do the action of setting the blue knob to "Z";
	Do the action of pulling the lever.
Definition: Activating-Shine is complete if the socket is activated.

Activating-Spin is a reversible task with venue the lighthouse apex.
Requirements for Activating-Spin:
	Do the action of setting the red knob to "Z";
	Do the action of setting the green knob to "Y";
	Do the action of setting the blue knob to "X";
	Do the action of pulling the lever.
Definition: Activating-Spin is complete if the socket is spinning.

Section - Resolution

Visiting-Franklin is a ghostly-required task with venue the machinery room.
Definition: Visiting-Franklin is complete if Franklin is at peace.

Chapter - Laying Spider To Rest

Laying-Spider-To-Rest is a puzzle. Laying-Spider-To-Rest requires Starting-The-Generator, Detonating-The-Dynamite, Giving-Spider-The-Coin.

Section - Accessing the Mine

Accessing-The-Mine is a puzzle. Accessing-The-Mine requires Activating-The-Projector-In-The-Cellar.

Activating-The-Projector-In-The-Cellar is a reversible lively-required task with venue the cellar.
Definition: Activating-The-Projector-In-The-Cellar is complete:
	If the projector is enclosed by the cellar and the projector is switched on, decide yes;
	If the player is in the excavation, decide yes.
	
Starting-The-Generator is a task with venue the Mine.
Requirements for Starting-The-Generator:
	Do the action of pouring the gas can into the generator;
	Do the action of using the generator.
Definition: Starting-The-Generator is complete if the generator is running.

Section - Detonating the Dynamite

Detonating-The-Dynamite is a puzzle. Detonating-The-Dynamite requires Attaching-Wire-To-Dynamite, Attaching-Wire-To-Detonator, Using-The-Detonator-A, Completing-The-Slot, Attaching-Wire-To-Dynamite-Again, Attaching-Wire-To-Detonator-Again, Using-The-Detonator-B.

Attaching-Wire-To-Dynamite is a task with venue the colonnade chamber.
Requirements for Attaching-Wire-To-Dynamite: 
	Do the action of tying the wire to the dynamite.
Definition: Attaching-Wire-To-Dynamite is complete if the wire is attached-to-dynamite.

Attaching-Wire-To-Detonator is a task with venue the mine.
Requirements for Attaching-Wire-To-Detonator: 
	Do the action of tying the wire to the detonator.
Definition: Attaching-Wire-To-Detonator is complete if the wire is attached-to-detonator.

Attaching-Wire-To-Dynamite-Again is a reversible task with venue the colonnade chamber.
Requirements for Attaching-Wire-To-Dynamite-Again: 
	Do the action of tying the wire to the dynamite.
Definition: Attaching-Wire-To-Dynamite-Again is complete if the wire is attached-to-dynamite or the detonator is detonated.

Attaching-Wire-To-Detonator-Again is a reversible task with venue the mine.
Requirements for Attaching-Wire-To-Detonator-Again: 
	Do the action of tying the wire to the detonator.
Definition: Attaching-Wire-To-Detonator-Again is complete if the wire is attached-to-detonator or the detonator is detonated.

Using-The-Detonator-A is a task with venue the mine.
Requirements for Using-The-Detonator-A:
	Do the action of using the detonator.
Definition: Using-The-Detonator-A is complete if the detonator is not untouched.

Using-The-Detonator-B is a task with venue the mine.
Requirements for Using-The-Detonator-B:
	Do the action of using the detonator.
Definition: Using-The-Detonator-B is complete if the detonator is detonated.

Completing-The-Slot is a puzzle. Completing-The-Slot requires Locating-The-Paddle-Fuse, Completing-The-Slot-A.

Locating-The-Paddle-Fuse is a task with venue the colonnade chamber. [Assuming the fuse is buried]
Requirements for Locating-The-Paddle-Fuse:
	Do the action of digging.
Definition: Locating-The-Paddle-Fuse is complete if the location of the paddle fuse is not nothing.

Completing-The-Slot-A is a task with venue the mine.
Requirements for Completing-The-Slot-A:
	Do the action of inserting the paddle fuse into the slot.
Definition: Completing-The-Slot-A is complete if the slot is complete.

Section - Giving the treasure to Spider

Giving-Spider-The-Coin is a ghostly-required task with venue the Jetty.
Requirements for Giving-Spider-The-Coin:
	Do the action of giving the gold doubloon to Spider.
Definition: Giving-Spider-The-Coin is complete if Spider is at peace.

Chapter - Laying Elizabeth to rest

Laying-Elizabeth-To-Rest is a puzzle. Laying-Elizabeth-To-Rest requires Collecting-The-Charms, Assembling-The-Bracelet, Exchanging-The-Ring.

Collecting-The-Charms is a puzzle. Collecting-The-Charms is not puzzle-sequential. Collecting-The-Charms requires Acquiring-The-Fire-Hydrant-Charm, Acquiring-The-Hook-Charm, Acquiring-The-Lighthouse-Charm, Acquiring-The-Thimble-Charm, Acquiring-The-Pelican-Charm, Acquiring-The-Slipper-Charm.

Section - Collecting the charms - Fire Hydrant

Acquiring-The-Fire-Hydrant-Charm is a puzzle. Acquiring-The-Fire-Hydrant-Charm requires Get-The-Ladder-A, Climbing-The-Ladder-In-The-Jetty, Examining-The-Nest, Taking-The-Fire-Hydrant-Charm.

Get-The-Ladder-A is a reversible task with venue the jetty.
Requirements for Get-The-Ladder-A:
	Do the action of taking the ladder.
Definition: Get-The-Ladder-A is complete if the player encloses the ladder or the ladder is in the jetty or (the fire hydrant charm is not in the nest and the fire hydrant charm is not hidden).

Climbing-The-Ladder-In-The-Jetty is a reversible task with venue the jetty.
Requirements for Climbing-The-Ladder-In-The-Jetty:
	Do the action of climbing the ladder.
Definition: Climbing-The-Ladder-In-The-Jetty is complete if the player is enclosed by the ladder or (the fire hydrant charm is not in the nest and the fire hydrant charm is not hidden).

Examining-The-Nest is a task with venue the jetty.
Requirements for Examining-The-Nest:
	Do the action of examining the nest.
Definition: Examining-The-Nest is complete if the fire hydrant charm is not hidden.

Taking-The-Fire-Hydrant-Charm is a reversible task with venue the jetty.
Requirements for Taking-The-Fire-Hydrant-Charm:
	Do the action of taking the fire hydrant charm.
Definition: Taking-The-Fire-Hydrant-Charm is complete if the fire hydrant charm is enclosed by the player or Gerald wears the bracelet.

Every turn:
	Now the venue of Get-The-Ladder-A is the location of the ladder;
	Now the venue of Taking-The-Fire-Hydrant-Charm is the location of the fire hydrant charm.
	
Section - Collecting the charms - Hook

Acquiring-The-Hook-Charm is a puzzle. Acquiring-The-Hook-Charm requires Ask-Spider-About-Hook, Take-Hook-Charm.

Ask-Spider-About-Hook is a ghostly-required task with venue the jetty.
Requirements for Ask-Spider-About-Hook:
	Do the action of quizzing Spider about the spider-hook.
Definition: Ask-Spider-About-Hook is complete if Spider does not enclose the spider-hook or the hook charm is on-stage.

Take-Hook-Charm is a reversible task.
Requirements for Take-Hook-Charm:
	Do the action of taking the hook charm.
Definition: Take-Hook-Charm is complete if the player encloses the hook charm  or Gerald wears the bracelet.

Every turn:
	Now the venue of Take-Hook-Charm is the location of the hook charm.
	

Section - Collecting the charms - Lighthouse

Acquiring-The-Lighthouse-Charm is a puzzle. Acquiring-The-Lighthouse-Charm requires Examining-The-Eagles-Nest, Take-Lighthouse-Charm.
The dependancies of Acquiring-The-Lighthouse-Charm are { Fixing-The-Elevator }.

Examining-The-Eagles-Nest is a task with venue the lighthouse roof.
Requirements for Examining-The-Eagles-Nest:
	Do the action of examining the eagles nest.
Definition: Examining-The-Eagles-Nest is complete if the lighthouse charm is not hidden.

Take-Lighthouse-Charm is a reversible task.
Requirements for Take-Lighthouse-Charm:
	Do the action of taking the lighthouse charm.
Definition: Take-Lighthouse-Charm is complete if the player encloses the lighthouse charm or Gerald wears the bracelet.

Every turn: 
	Now the venue of Take-Lighthouse-Charm is the location of the lighthouse charm.	


Section - Collecting the charms - Thimble

Acquiring-The-Thimble-Charm is a puzzle. Acquiring-The-Thimble-Charm requires Take-Thimble-Charm.

Take-Thimble-Charm is a reversible task.
Requirements for Take-Thimble-Charm:
	Do the action of taking the thimble charm.
Definition: Take-Thimble-Charm is complete if the player encloses the thimble charm or Gerald wears the bracelet.

Every turn: 
	Now the venue of Take-Thimble-Charm is the location of the thimble charm.
	


Section - Collecting the charms - Pelican

Acquiring-The-Pelican-Charm is a puzzle. Acquiring-The-Pelican-Charm requires Take-Pelican-Charm.
The dependancies of Acquiring-The-Pelican-Charm are { Smack-Shoo-B }.

Take-Pelican-Charm is a reversible task.
Requirements for Take-Pelican-Charm:
	Do the action of taking the pelican charm.
Definition: Take-Pelican-Charm is complete if the player encloses the pelican charm or Gerald wears the bracelet.

Every turn: 
	Now the venue of Take-Pelican-Charm is the location of the pelican charm.
	


Section - Collecting the charms - Slipper


Acquiring-The-Slipper-Charm is a puzzle. Acquiring-The-Slipper-Charm requires Take-Slipper-Charm.
The dependancies of Acquiring-The-Slipper-Charm are { Accessing-The-Bay-Room }.

Take-Slipper-Charm is a reversible task.
Requirements for Take-Slipper-Charm:
	Do the action of taking the slipper charm.
Definition: Take-Slipper-Charm is complete if the player encloses the slipper charm or Gerald wears the bracelet.

Every turn: 
	Now the venue of Take-Slipper-Charm is the location of the slipper charm.
	


Section - Assembling the Bracelet

Assembling-The-Bracelet is a puzzle. Assembling-The-Bracelet requires Acquiring-The-Bracelet, Putting-Hydrant-On-Bracelet, Putting-Hook-On-Bracelet, Putting-Lighthouse-On-Bracelet, Putting-Thimble-On-Bracelet, Putting-Pelican-On-Bracelet, Putting-Slipper-On-Bracelet.

Acquiring-The-Bracelet is a puzzle. Acquiring-The-Bracelet requires Having-A-Charm, Showing-A-Charm-To-Elizabeth.

Having-A-Charm is a reversible task.
The dependancies of Having-A-Charm are { Taking-The-Fire-Hydrant-Charm }.
Definition: Having-A-Charm is complete if the player encloses a charm or Elizabeth does not enclose the bracelet.
[Every Turn:
	If the player does not enclose a charm:
		Now the dependancies of Having-A-Charm are { Taking-The-Fire-Hydrant-Charm };
	Otherwise:
		Now the dependancies of Having-A-Charm are {}.]
		
Showing-A-Charm-To-Elizabeth is a ghostly-required task with venue the square.
Definition: Showing-A-Charm-To-Elizabeth is complete if Elizabeth does not enclose the bracelet.
Every turn:
	If the player encloses a charm:
		Let C be a random charm enclosed by the player;
		Let D be the action of giving C to Elizabeth;
		Add D to action-sequence of Showing-A-Charm-To-Elizabeth;
		Truncate action-sequence of Showing-A-Charm-To-Elizabeth to the last 1 entries.
		

Putting-Hydrant-On-Bracelet is a reversible task.
Requirements for Putting-Hydrant-On-Bracelet:
	Do the action of putting the fire hydrant charm on the bracelet.
Definition: Putting-Hydrant-On-Bracelet is complete if the fire hydrant charm is on the bracelet.

Putting-Hook-On-Bracelet is a reversible task.
Requirements for Putting-Hook-On-Bracelet:
	Do the action of putting the hook charm on the bracelet.
Definition: Putting-Hook-On-Bracelet is complete if the hook charm is on the bracelet.


Putting-Lighthouse-On-Bracelet is a reversible task.
Requirements for Putting-Lighthouse-On-Bracelet:
	Do the action of putting the lighthouse charm on the bracelet.
Definition: Putting-Lighthouse-On-Bracelet is complete if the lighthouse charm is on the bracelet.


Putting-Thimble-On-Bracelet is a reversible task.
Requirements for Putting-Thimble-On-Bracelet:
	Do the action of putting the thimble charm on the bracelet.
Definition: Putting-Thimble-On-Bracelet is complete if the thimble charm is on the bracelet.


Putting-Pelican-On-Bracelet is a reversible task.
Requirements for Putting-Pelican-On-Bracelet:
	Do the action of putting the pelican charm on the bracelet.
Definition: Putting-Pelican-On-Bracelet is complete if the pelican charm is on the bracelet.

Putting-Slipper-On-Bracelet is a reversible task.
Requirements for Putting-Slipper-On-Bracelet:
	Do the action of putting the slipper charm on the bracelet.
Definition: Putting-Slipper-On-Bracelet is complete if the slipper charm is on the bracelet.



Section - Exchanging the Ring

Exchanging-The-Ring is a puzzle. Exchanging-The-Ring requires Giving-The-Bracelet-To-Gerald and Giving-The-Ring-To-Elizabeth.

Giving-The-Bracelet-To-Gerald is a lively-required task with venue the square.
Requirements for Giving-The-Bracelet-To-Gerald:
	Do the action of giving the bracelet to Gerald.
Definition: Giving-The-Bracelet-To-Gerald is complete if Gerald wears the bracelet.

Giving-The-Ring-To-Elizabeth is a ghostly-required task with venue the square.
Requirements for Giving-The-Ring-To-Elizabeth:
	Do the action of giving the engagement ring to Elizabeth.
Definition: Giving-The-Ring-To-Elizabeth is complete if Elizabeth is at peace.



Part - Brisbane and Death

Final-Resolution is a puzzle. Final-Resolution requires Following-Death, Accessing-The-Graveyard, Entering-The-Mausoleum.

Section - Following Death

Following-Death is a puzzle. Following-Death requires Initiating-The-Death-Sequence, Following-Death-B.

Initiating-The-Death-Sequence is a reversible task with venue the bay room.
The dependancies of Initiating-The-Death-Sequence are { Accessing-The-Bay-Room }. [Somewhat redundant: This should be done already.]
Requirements for Initiating-The-Death-Sequence:
	Do the action of quizzing Death about Death.
Definition: Initiating-The-Death-Sequence is complete if Death is not in the bay room.

Following-Death-B is a task.
Definition: Following-Death-B is complete if Death is in the graveyard.
Every turn:
	Now the venue of Following-Death-B is the location of Death.

Section - Accessing The Graveyard

Accessing-The-Graveyard is a puzzle. Accessing-The-Graveyard requires Filling-The-Glass-With-Rum, Filling-The-Glass-With-Wine.

Filling-The-Glass-With-Rum is a task with venue the chapel.
Requirements for Filling-The-Glass-With-Rum:
	Do the action of pouring the amber bottle into the crystal glass.
Definition: Filling-The-Glass-With-Rum is complete if the amber bottle is empty or the bone key is not enclosed by Brisbane.

Filling-The-Glass-With-Wine is a task with venue the chapel.
Requirements for Filling-The-Glass-With-Wine:
	Do the action of pouring the communion wine into the crystal glass.
Definition: Filling-The-Glass-With-Wine is complete if the communion wine is empty or the bone key is not enclosed by Brisbane.




Section - Entering The Mausoleum

Entering-The-Mausoleum is a puzzle. Entering-The-Mausoleum requires Getting-The-Watch, Opening-The-Watch, Examining-The-Watch, Setting-The-Clock, Entering-The-Mausoleum-B.

Getting-The-Watch is a reversible task.
Requirements for Getting-The-Watch:
	Do the action of taking the pocket watch.
Definition: Getting-The-Watch is complete if the player encloses the pocket watch.
Every turn:
	Now the venue of Getting-The-Watch is the location of the pocket watch.

Opening-The-Watch is a reversible task with venue the graveyard.
Requirements for Opening-The-Watch:
	Do the action of opening the pocket watch.
Definition: Opening-The-Watch is complete if the pocket watch is open.

Examining-The-Watch is a task with venue the graveyard.
Requirements for Examining-The-Watch:
	Do the action of examining the pocket watch.
Definition: Examining-The-Watch is complete if the player-knows-time is true.

Player-knows-time is a truth-state that varies. Player-knows-time is false.
Carry out examining the pocket watch:
	If the pocket watch is open and the pocket watch is stopped:
		Now player-knows-time is true;
		Let C be the set time of the pocket watch;
		Let D be the action of time-setting the mausoleum clock to C;
		Add D to the action-sequence of Setting-The-Clock;
		Truncate action-sequence of Setting-The-Clock to the last 1 entries.

Setting-The-Clock is a reversible task with venue the graveyard.
Definition: Setting-The-Clock is complete if the mausoleum is not locked.

Entering-The-Mausoleum-B is a task with venue the graveyard.
Requirements for Entering-The-Mausoleum-B:
	Do the action of entering the mausoleum.
Definition: Entering-The-Mausoleum-B is complete if the player is in the mausoleum.
