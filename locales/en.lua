local Translations = {
    ["error"] = {
        ["not_enough_money"] = "You do not have enough money on the account!",
        ["promotion_not_allowed"] = "You cannot promote to this rank!",
        ["grade_not_found"] = "Promotion grade not found.",
        ["employee_not_in_city"] = "The person is not in the city.",
        ["cannot_fire_yourself"] = "You cannot fire yourself!",
    },
    ["success"] = {
        ["withdrawn_money"] = "You have withdrawn: ",
        ["deposited_money"] = "You have deposited: ",
        ["promoted_employee"] = "Successfully promoted!",
        ["employee_fired"] = "Employee has been fired!",
        ["employee_hired"] = "You have hired a new employee!",
    },
}

Lang = Lang or Locale:new({
	phrases = Translations,
	warnOnMissing = true,
})
