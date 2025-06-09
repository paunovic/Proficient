-- Should subscribe and have correct listeners called when message is published

Tests['test [subscribe] Subscribe without listener argument should have the correct listener called'] = function()
	local observer = makeObserver('MESSAGE')

	observer:Subscribe('MESSAGE')

	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 1)
	assertEquals(observer.result, 'MESSAGE')

	observer:Publish('DIFFERENT_MESSAGE')
	assertEquals(observer.calls, 1)
	assertEquals(observer.result, 'MESSAGE')

	observer:Publish('MESSAGE', 5)
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 5)
end

Tests['test [subscribe] Wubscribe with function reference argument should have the correct listener called'] = function()
	local observer = makeObserver()
	local target = makeObject('listener')

	observer:Subscribe('MESSAGE', function(...) target:listener(...) end)

	observer:Publish('DIFFERENT_MESSAGE')
	assertEquals(target.calls, 0)
	assertIsNil(target.result)

	observer:Publish('MESSAGE')
	assertEquals(target.calls, 1)
	assertEquals(target.result, 'listener')

	observer:Publish('MESSAGE', 5)
	assertEquals(target.calls, 2)
	assertEquals(target.result, 5)

	assertEquals(observer.calls, 0)
	assertIsNil(observer.result)
end

Tests['test [subscribe] Subscribe with object argument should have the correct listener called'] = function()
	local observer = makeObserver()
	local target = makeObject('MESSAGE')

	observer:Subscribe('MESSAGE', target)

	observer:Publish('MESSAGE')
	assertEquals(target.calls, 1)
	assertEquals(target.result, 'MESSAGE')

	observer:Publish('DIFFERENT_MESSAGE')
	assertEquals(target.calls, 1)
	assertEquals(target.result, 'MESSAGE')

	observer:Publish('MESSAGE', 5)
	assertEquals(target.calls, 2)
	assertEquals(target.result, 5)

	assertEquals(observer.calls, 0)
	assertIsNil(observer.result)
end

Tests['test [subscribe] Subscribe with a string argument should have the correct listener called'] = function()
	local observer = makeObserver('OnMessage')

	observer:Subscribe('MESSAGE', 'OnMessage')

	observer:Publish('DIFFERENT_MESSAGE')
	assertEquals(observer.calls, 0)
	assertIsNil(observer.result)

	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 1)
	assertEquals(observer.result, 'OnMessage')

	observer:Publish('MESSAGE', 5)
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 5)
end

Tests['test [subscribe] Subscribe with object and string arguments should have the correct listener called'] = function()
	local observer = makeObserver()
	local target = makeObject('OnMessage')

	observer:Subscribe('MESSAGE', target, 'OnMessage')

	observer:Publish('DIFFERENT_MESSAGE')
	assertEquals(target.calls, 0)
	assertIsNil(target.result)

	observer:Publish('MESSAGE')
	assertEquals(target.calls, 1)
	assertEquals(target.result, 'OnMessage')

	observer:Publish('MESSAGE', 5)
	assertEquals(target.calls, 2)
	assertEquals(target.result, 5)

	assertEquals(observer.calls, 0)
	assertIsNil(observer.result)
end

Tests['test [subscribe] Subscribing two listeners for one message should have both listeners called'] = function()
	local observer = makeObserver('MESSAGE', 'OnMessage')

	observer:Subscribe('MESSAGE')
	observer:Subscribe('MESSAGE', 'OnMessage')

	observer:Publish('MESSAGE', 5)
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 5)

	observer:Publish('DIFFERENT_MESSAGE')
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 5)
end

Tests['test [subscribe] Subscribe with object of listeners as argument should have all those listeners called'] = function()
	local observer = makeObserver('MESSAGE1', 'MESSAGE2', 'ObserverMessage')
	local target = makeObject('MESSAGE1', 'MESSAGE3', 'TargetMessage')

	observer:Subscribe({MESSAGE1 = 'MESSAGE1', MESSAGE2 = 'ObserverMessage', MESSAGE3 = target})
	observer:Subscribe({MESSAGE1 = target, MESSAGE3 = function(...) target:TargetMessage(...) end})

	observer:Publish('MESSAGE1')
	assertEquals(observer.calls, 1)
	assertEquals(observer.result, 'MESSAGE1')
	assertEquals(target.calls, 1)
	assertEquals(target.result, 'MESSAGE1')

	observer:Publish('MESSAGE2')
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 'ObserverMessage')
	assertEquals(target.calls, 1)
	assertEquals(target.result, 'MESSAGE1')

	observer:Publish('MESSAGE3', 5)
	assertEquals(observer.calls, 2)
	assertEquals(observer.result, 'ObserverMessage')
	assertEquals(target.calls, 3)
	assertEquals(target.result, 5)
end
