-- Should not fire on disabled module/addon and should not let errors in one listener break others

Tests['test [publish] Should not publish if object is disabled'] = function()
	local observer = makeObserver('MESSAGE')
	local enabledState = true
	observer.IsEnabled = function() return enabledState end

	observer:Subscribe('MESSAGE')
	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 1)

	enabledState = false

	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 1)
end

Tests['test [publish] Should not throw errors for non-existent listeners, but should call the error handler'] = function()
	local observer = makeObserver('MESSAGE1')
	local target = makeObject('MESSAAGE3')
	handledErrors = 0

	observer:Subscribe('MESSAGE1', 'NonExistantFunction')
	observer:Subscribe('MESSAGE2', target)
	observer:Subscribe('MESSAGE3', target, 'NonExistantFunction')

	observer:Publish('MESSAGE1')
	assertEquals(handledErrors, 1)

	observer:Publish('MESSAGE2')
	assertEquals(handledErrors, 2)

	observer:Publish('MESSAGE3')
	assertEquals(handledErrors, 3)
end

Tests['test [publish] Should not let errors in listeners break execution, but should call the error handler'] = function()
	local observer = makeObserver('MESSAGE1', 'MESSAGE2')
	observer.ThrowError = function() error() end
	handledErrors = 0

	observer:Subscribe('MESSAGE1')
	observer:Subscribe('MESSAGE1', 'ThrowError')

	observer:Subscribe('MESSAGE2', 'ThrowError')
	observer:Subscribe('MESSAGE2')

	observer:Publish('MESSAGE1')
	assertEquals(handledErrors, 1)
	assertEquals(observer.calls, 1)
	assertEquals(observer.result, 'MESSAGE1')

	observer:Publish('MESSAGE2')
	assertEquals(handledErrors, 2)
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 'MESSAGE2')
end
