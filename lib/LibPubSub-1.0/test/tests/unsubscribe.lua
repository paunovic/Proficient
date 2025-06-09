-- Should unsubscribe and stop listeners from being called when message is published

Tests['test [unsubscribe] Unsubscribing a listener should stop it from being called'] = function()
	local observer = makeObserver('MESSAGE', 'ObserverMessage')
	local target = makeObject('MESSAGE', 'TargetMessage')
	local fn = function(...) target:TargetMessage(...) end

	observer:Subscribe('MESSAGE')
	observer:Subscribe('MESSAGE', 'ObserverMessage')
	observer:Subscribe('MESSAGE', target)
	observer:Subscribe('MESSAGE', target, 'TargetMessage')
	observer:Subscribe('MESSAGE', fn)

	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 2)
	assertEquals(target.calls, 3)

	observer:Unsubscribe('MESSAGE')
	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 3)
	assertEquals(target.calls, 6)

	observer:Unsubscribe('MESSAGE', 'ObserverMessage')
	observer:Unsubscribe('MESSAGE', target)
	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 3)
	assertEquals(target.calls, 8)

	observer:Unsubscribe('MESSAGE', target, 'TargetMessage')
	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 3)
	assertEquals(target.calls, 9)

	observer:Unsubscribe('MESSAGE', fn)
	observer:Publish('MESSAGE')
	assertEquals(observer.calls, 3)
	assertEquals(target.calls, 9)
end

Tests['test [unsubscribe] Unsubscribing an object with listeners should stop those listeners from being called'] = function()
	local observer = makeObserver('MESSAGE1', 'MESSAGE2', 'OnMessage')

	observer:Subscribe('MESSAGE1')
	observer:Subscribe('MESSAGE2')
	observer:Subscribe('MESSAGE2', 'OnMessage')

	observer:Publish('MESSAGE1')
	observer:Publish('MESSAGE2')
	assertEquals(observer.calls, 3)

	observer:Unsubscribe({MESSAGE1 = 'MESSAGE1', MESSAGE2 = 'OnMessage'})
	observer:Publish('MESSAGE1')
	assertEquals(observer.calls, 3)
	observer:Publish('MESSAGE2')
	assertEquals(observer.calls, 4)
	assertEquals(observer.result, 'MESSAGE2')
end

Tests['test [unsubscribe] UnsubscribeAll should should stop any subscribed listeners from being called'] = function()
	local observer = makeObserver('MESSAGE1', 'MESSAGE2')

	observer:Subscribe('MESSAGE1')
	observer:Subscribe('MESSAGE1')
	observer:Subscribe('MESSAGE2')
	observer:Subscribe('MESSAGE2')
	observer:Subscribe('MESSAGE2')

	observer:Publish('MESSAGE1')
	observer:Publish('MESSAGE2')
	assertEquals(observer.calls, 5)

	observer:UnsubscribeAll()
	observer:Publish('MESSAGE1')
	assertEquals(observer.calls, 5)
	observer:Publish('MESSAGE2')
	assertEquals(observer.calls, 5)
end
