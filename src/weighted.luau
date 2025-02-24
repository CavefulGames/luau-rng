return function<V>(arr: { V }, weights: { number }, trim: boolean?): () -> V
	if #arr ~= #weights then
		error("Length of array and weights must match")
	end

	local sum = 0
	for _, weight in ipairs(weights) do
		if type(weight) ~= "number" then
			error("All weights must be numbers")
		end

		if weight > 0 then
			sum += weight
		end
	end

	if sum == 0 then
		error("No valid entries in array weights")
	end

	local selected = math.random() * sum

	return function()
		local total = 0
		local lastGoodIdx = -1
		local chosenIdx: number

		for i, weight in weights do
			total = total + weight
			if weight > 0 then
				if selected <= total then
					chosenIdx = i
					break
				end
				lastGoodIdx = i
			end

			if i == #weights then
				chosenIdx = lastGoodIdx
			end
		end

		local chosen = arr[chosenIdx]

		if trim then
			table.remove(arr, chosenIdx)
			table.remove(weights, chosenIdx)
		end

		return chosen
	end
end
