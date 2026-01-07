#THIS WILL BE INHERITED AND IMPLEMENTED BY THE SUBSTATES
class_name State
extends Node

var state_machine: FiniteStateMachine
var enemy = null # Reference to the NPC itself

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass
