extends IState
class_name BehaviorState

var character: Character = null


func init(args := {}) -> IState:
	super.init(args)
	character = args["character"]
	return self
