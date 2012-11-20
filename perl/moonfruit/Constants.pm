package Constants;

use Switch;
use strict;

use constant {
	DEFAULT_VITALITY_FISH => 30,
	DEFAULT_VITALITY_SNAIL => 50,
	VITALITY_DEAD => 0,
	VITALITY_REMOVED => -1, # dead but also no longer in the tank
};

use constant DEFAULT_CAPACITY => 10;
use constant START_TEMPERATURE => 20;
use constant PIRANHA_MIN_TEMP => 15;

use constant {
	DEPTH_SURFACE => 0,
	DEPTH_TOP	  => 10,
	DEPTH_MIDDLE  => 30,
	DEPTH_BOTTOM  =>50,
};


1;