-- Should initialise correctly

Tests['test [init] Embed should add functions to existing object'] = function()
	local target = {key = 'value'}
	local observer = lib:Embed(target)

	assertEquals(target, observer)
	assertEquals(target.key, 'value')
	assertIsFunction(target.Publish)
	assertIsFunction(target.Subscribe)
	assertIsFunction(target.Unsubscribe)
end

Tests['test [init] New should return a new object with PubSub functions'] = function()
	local observer = lib:New()

	assertIsTable(observer)
	assertIsFunction(observer.Publish)
	assertIsFunction(observer.Subscribe)
	assertIsFunction(observer.Unsubscribe)
end
