extends IState
class_name CharacterState

var character: Character = null


func init(args := {}):
	character = args["character"]
	return self
