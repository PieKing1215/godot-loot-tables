@tool
class_name LTArithmeticOperation
extends LTContextOperation

@export var operand_a: String = "0"
@export var operand_b: String = "0"
@export var operator: Operator = Operator.Add
@export var output_id: String = ""

enum Operator {
	Add,
	Subtract,
	Multiply,
	Divide,
	Pow,
	Mod,
}

func apply(ctx: Dictionary) -> Dictionary:
	var res = ctx.duplicate()
	
	if output_id != null && !output_id.is_empty():
		var val_a: float = get_float_or_constant_or_default(ctx, operand_a, 0.0)
		var val_b: float = get_float_or_constant_or_default(ctx, operand_b, 0.0)
		
		match operator:
			Operator.Add:
				res[output_id] = val_a + val_b
			Operator.Subtract:
				res[output_id] = val_a - val_b
			Operator.Multiply:
				res[output_id] = val_a * val_b
			Operator.Divide:
				res[output_id] = val_a / val_b
			Operator.Pow:
				res[output_id] = pow(val_a, val_b)
			Operator.Mod:
				res[output_id] = fposmod(val_a, val_b)
	
	return res

