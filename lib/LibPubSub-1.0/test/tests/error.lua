-- Should throw errors for invalid arguments

Tests['test [error] Subscribe call without arguments should throw an error'] = function()
	local observer = makeObserver()

	assertError(observer.Subscribe)
	assertError(observer.Subscribe, observer) -- only passing "self"
end

Tests['test [error] Unsubscribe call without arguments should throw an error'] = function()
	local observer = makeObserver()

	assertError(observer.Unsubscribe)
	assertError(observer.Unsubscribe, observer) -- only passing "self"
end

Tests['test [error] Publish call without arguments should throw an error'] = function()
	local observer = makeObserver()

	assertError(observer.Publish)
	assertError(observer.Publish, observer) -- only passing "self"
end

Tests['test [error] Subscribe call with invalid arguments should throw an error'] = function()
	local observer = makeObserver()

	assertError(observer.Subscribe, observer, nil)
	assertError(observer.Subscribe, observer, 1)
	assertError(observer.Subscribe, observer, true)
	assertError(observer.Subscribe, observer, function() end)

	assertError(observer.Subscribe, observer, 'MESSAGE', 1)
	assertError(observer.Subscribe, observer, 'MESSAGE', true)

	assertError(observer.Subscribe, observer, 'MESSAGE', {}, 1)
	assertError(observer.Subscribe, observer, 'MESSAGE', {}, true)
	assertError(observer.Subscribe, observer, 'MESSAGE', {}, function() end)
end

Tests['test [error] Unsubscribe call with invalid arguments should throw an error'] = function()
	local observer = makeObserver()

	assertError(observer.Unsubscribe, observer, nil)
	assertError(observer.Unsubscribe, observer, 1)
	assertError(observer.Unsubscribe, observer, true)
	assertError(observer.Unsubscribe, observer, function() end)

	assertError(observer.Unsubscribe, observer, 'MESSAGE', 1)
	assertError(observer.Unsubscribe, observer, 'MESSAGE', true)

	assertError(observer.Unsubscribe, observer, 'MESSAGE', {}, 1)
	assertError(observer.Unsubscribe, observer, 'MESSAGE', {}, true)
	assertError(observer.Unsubscribe, observer, 'MESSAGE', {}, function() end)
end

Tests['test [error] Publish call with invalid arguments should throw an error'] = function()
	local observer = makeObserver()

	assertError(observer.Publish, observer, nil)
	assertError(observer.Publish, observer, 1)
	assertError(observer.Publish, observer, true)
	assertError(observer.Publish, observer, {})
	assertError(observer.Publish, observer, function() end)
end
