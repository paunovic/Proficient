LibPubSub-1.0
=============

Simple embeddable publish-subscribe implementation.

Including LibPubSub functionality
---------------------------------

The easiest method for utilising LibPubSub is a mixin, like so:

	MyAddon = LibStub('AceAddon-3.0'):NewAddon('MyAddon', 'LibPubSub-1.0')

If you're not using AceAddon, you can still embed LibPubSub in an
object/table via LibPubSub's Embed() function:

	LibStub('LibPubSub-1.0'):Embed(MyObject)

If you don't want to embed LibPubSub's methods in your objects, you can
get a separate LibPubSub object:

	local Observer = LibStub('LibPubSub-3.0'):New()

In the following examples, please replace `Observer` with the right
object.

API
---

### Observer:Publish(message, ...)

This calls all listeners subscribed to this message, and passes the
arguments given after the message. Multiple objects or functions can be
subscribed to the same message.

#### Parameters

- **message** *(string)*
	- The message to publish
- **...** *(mixed)*
	- Any arguments to pass to the listeners

### Observer:Subscribe(message\[, object]\[, function])

There are multiple ways to subscribe to messages, and multiple listeners
can be attached for the same message:

	Observer:Subscribe('NAME_OF_MESSAGE') -- calls Observer:NAME_OF_MESSAGE()
	Observer:Subscribe('NAME_OF_MESSAGE', funcref) -- calls funcref()
	Observer:Subscribe('NAME_OF_MESSAGE', 'FunctionName') -- calls Observer:FunctionName()
	Observer:Subscribe('NAME_OF_MESSAGE', Object) -- calls Object:NAME_OF_MESSAGE()
	Observer:Subscribe('NAME_OF_MESSAGE', Object, 'FunctionName') -- calls Object:FunctionName()

The second, third and fourth versions of attaching listeners can also be
passed as a table, as shorthand for attaching listeners for multiple
messages:

	Observer:Subscribe({NAME_OF_MESSAGE = funcref, OTHER_MESSAGE = 'FunctionName'})

The arguments passed to the listener are the arguments passed to the
`Publish` function after the message name.

#### Parameters

- **message** *(string)*
	- The message to subscribe to
- **object** *(table)*
	- The object the function should be called on
- **function** *(string/funcref)*
	- The function to call

### Observer:Unsubscribe(message\[, object]\[, function])

This works exactly the same as subscribing to a message. Note that you
need to pass the same arguments to `Unsubscribe` as you passed to
`Subscribe` to remove a listener for a message. That means that, if you
subscribed using `Observer:Subscribe('NAME_OF_MESSAGE', funcref)` you
need to unsubscribe using `Observer:Unsubscribe('NAME_OF_MESSAGE',
funcref)`.

The possible ways to call this function:

	Observer:Unsubscribe('NAME_OF_MESSAGE')
	Observer:Unsubscribe('NAME_OF_MESSAGE', funcref)
	Observer:Unsubscribe('NAME_OF_MESSAGE', 'FunctionName')
	Observer:Unsubscribe('NAME_OF_MESSAGE', Object)
	Observer:Unsubscribe('NAME_OF_MESSAGE', Object, 'FunctionName')
	Observer:Unsubscribe({NAME_OF_MESSAGE = funcref, OTHER_MESSAGE = 'FunctionName'})

#### Parameters

- **message** *(string)*
	- The message to unsubscribe from
- **object** *(table)*
	- The object the function would be called on
- **function** *(string/funcref)*
	- The subscribed function

### Observer:UnsubscribeAll()

Removes all currently subscribed listeners immediately.

#### Parameters

None.
