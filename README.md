# Learn Redux for Dart

Start with the Stagehand web-simple template:
```bash
mkdir redux_dart_basic_tutorial
cd redux_dart_basic_tutorial
stagehand web-simple
pub get
```

## Basics

Don't be fooled by all the fancy talk about reducers,
middleware, store enhancers--Redux is incredibly simple.

In this gude, we'll walk through the process of creating
a simple Todo app.

* [Actions](#actions)
* [Reducers](#reducers)
* [Store](#store)
* [Data Flow](#data-flow)
* [Usage with OverReact](#usage-with-overreact)
* [Example: Todo List](#example-todo-list)

## Actions

First, let's define some actions.

**Actions** are payloads of information that send data from your
application to your store. They are the *only* source of information
for the store. You send them to the store using
[`store.dispatch()`](https://pub.dev/documentation/redux/latest/redux/Store/dispatch.html)

Unlike in JavaScript, in Dart, an action class can be created
to add typing to the actions passed into dispatch.

While it can make life easier, this practice is optional as long
as the reducer receives a valid type and value parameter.
```dart
class Action {
  Action({this.type, this.value});

  final String type;
  final dynamic value;
}
```

Here's an example action which represents adding a new todo
item:
```dart
class AddTodo extends Action {
  AddTodo([String text]) : super(type: 'ADD_TODO', value: text);
}
```

We'll add one more action type to describe a user ticking
off a todo as completed. We refer to a particular todo by
`index` because we store htem in an array. In a real
app, it is wiser to generate a unique ID every time
something new is created.

```dart
class ToggleTodo extends Action {
  ToggleTodo([int index]) : super(type: 'TOGGLE_TODO', value: index);
}
```

It's a good idea to pass as little data in each action as possible.
For example, it's better to pass `index` than the whole todo object.

Finally, we'll add one more action type for changing the
currently visible todos.

```dart
class SetVisibilityFilter extends Action {
  SetVisibilityFilter([VisibilityFilter filter]) : super(type: 'SET_VISIBILITY_FILTER', value: filter);
}
```

In [traditional Flux](https://pub.dev/packages/w_flux), actions often trigger a dispatch
when invoked, like so:
```dart
// define an action
final Action<String> addTodo = new Action<String>();
// dispatch the action with a payload
addTodo('someTodo');
```

In Redux this is *not* the case. Instead, to actually
initiate a dispatch, pass the result to the `dispatch()`
function:

```dart
store.dispatch(AddTodo(someText));
store.dispatch(ToggleTodo(someIndex));
```

The `dispatch()` function can be accessed direclty from the
store as 
[`store.dispatch()`](https://pub.dev/documentation/redux/latest/redux/Store/dispatch.html)
, but more liekly you'll access it using a helper like
[OverReact Redux](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md)'s `connect()`.

### Source Code
`lib/src/actions.dart`
```dart
class Action {
  Action({this.type, this.value});

  final String type;
  final dynamic value;
}

enum VisibilityFilter { showAll, showCompleted, showActive }

class AddTodo extends Action {
  AddTodo([String text]) : super(type: 'ADD_TODO', value: text);
}

class ToggleTodo extends Action {
  ToggleTodo([int index]) : super(type: 'TOGGLE_TODO', value: index);
}

class SetVisibilityFilter extends Action {
  SetVisibilityFilter([VisibilityFilter filter]) : super(type: 'SET_VISIBILITY_FILTER', value: filter);
}
```

### Next Steps
Now let's [define some reducers](#reducers) to specify how
the state updates when you dispatch these actions!

## Reducers

**Reducers** specify how the application's state changes in
response to [actions](#actions) sent to the store. Remember
that actions only describe *what happened*, but don't describe
how the application's state changes.

### Designing the State Shape

In Redux, all the application state is stored as a single
object. It's a good idea to think of its shape before writing
any code. What's the minimal reprsentation of your app's state
as an object?

For our todo app, we want to store two different things:

* The currently selected visibility filter.
* The actual list of todos.

You'll often find that you need to store some data, as well
as some UI state, in the state tree. This is fine, but try to keep
the data seperate from the UI state.

```dart
class Todo {
  String text;
  bool completed;
}

class AppState {
  VisibilityFilter visibilityFilter;
  List<Todo> todos;
}
```

> **Note on Relationships**
>
> In a more complex app, you're going to want different entities
to reference each other. We suggest that you keep your state as
normalized as possible, without any nesting. Keep every entity
in an object stored with an ID as a key, and use IDs to
reference it from other entities or lists. Think of the app's
state as a database. This approach is described in
[normalizr's](https://github.com/paularmstrong/normalizr)
documentation in detail. For example, keeping
`Map<int, Todo> todosById` and `List<int> todos` inside the state
would be a better idea in a real app, but we're keeping the
example simple.

### Handling Actions

Now that we've decided what our state object looks like, we're
ready to write a reducer for it. The reducer is a pure function
that takes the previous state and an action and returns the
next state.

```dart
AppState appStateReducer(AppState state, dynamic action) {
  /* implementation */
}
```

It's called a reducer because it's the type of function you
would pass to
[Array.prototype.reduce(reducer, ?initialValue)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce).
It's very important that the reducer stays pure.
Things you should **never** do inside a reducer:

* Mutate its arguments;
* Perform side effects like API calls and routing transitions;
* Call non-pure functions, e.g. `DateTime.now()` and `Random()` 

**Given the same arguments, it should calculate the next
state and return it. No surprises. No side effects. No API calls.
No mutations. Just a calculation.**

With this out of the way, let's start writing our reducer
by gradually teaching it to understand the [actions](#actions)
we defined earlier.

We'll start by specifying the initial state.
```dart
class AppState {
  VisibilityFilter visibilityFilter;
  List<Todo> todos;

  AppState({this.visibilityFilter, this.todos});

  AppState.emptyState()
      : visibilityFilter = VisibilityFilter.showAll,
        todos = [];
}

AppState appStateReducer(AppState state, dynamic action) {
  // For now, don't handle any actions
  // and just return the state given to us.
  return state;
}
```

Now let's handle `SetVisibilityFilter`. All it needs to do
is change `visibilityFilter` on the state. Easy:
```dart
class AppState {
  // -- snip --
  AppState.updateState(AppState oldState, {VisibilityFilter visibilityFilter, List<Todo> todos})
      : visibilityFilter = visibilityFilter ?? oldState.visibilityFilter,
        todos = todos ?? oldState.todos;
}

AppState appStateReducer(AppState state, dynamic action) {
  if (action is SetVisibilityFilter) {
    return AppState.updateState(state, visibilityFilter: action.value);
  } else {
    return state;
  }
}
``` 

Note that:

1. **We don't mutate the `state`. We create a copy with
`AppState.updateState()`.

2. **We return the previous `state` in the `else` case.** It's
important to return the previous `state` for any unknown
action.`

### Handling More Actions

We have two more actions to handle! Just like we did with
`SetVisibilityFilter`, we'll import `AddTodo` and `ToggleTodo`
actions and then extend our reducer to handle `AddTodo`.

```dart
import 'package:redux_dart_basic_tutorial/src/actions.dart';

class Todo {
  String text;
  bool completed;

  Todo(this.text) : completed = false;
}

// -- snip --

AppState appStateReducer(AppState state, dynamic action) {
  if (action is SetVisibilityFilter) {
    return AppState.updateState(state, visibilityFilter: action.value);
  } else if (action is AddTodo) {
    return AppState.updateState(state, todos: [...state.todos, Todo(action.value)]);
  } else {
    return state;
  }
}
```

Just like before, we never write directly to `state` or its fields,
and instead we return new objects. The new `todos` is equal
to the old `todos` concatenated with a single new item at the
end. The fresh todo was constructed using the data from the action.

Finally, the implementation of the `ToggleTodo` shouldn't come
as a complete surprise:

```dart
  } else if (action is ToggleTodo) {
    return AppState.updateState(state,
        todos: state.todos
            .asMap()
            .map((index, todo) {
              if (index == action.value) {
                return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
              }
              return MapEntry(index, todo);
            })
            .values
            .toList());
```

Because we want to update a specific item in the array
without resorting to mutations, we have to create a new array
with the same items except the item at the index. If you find
yourself often writing such operations, it's a good idea to use
a helper like
[built_collection](https://github.com/google/built_collection.dart)
or
[built_value](https://github.com/google/built_value.dart#built-values-for-dart).
Just remember to never assign to anything
inside the `state` unless you clone it first.

### Splitting Reducers
Here is our code so far. It is rather verbose:
```dart
AppState appStateReducer(AppState state, dynamic action) {
  if (action is SetVisibilityFilter) {
    return AppState.updateState(state, visibilityFilter: action.value);
  } else if (action is AddTodo) {
    return AppState.updateState(state, todos: [...state.todos, Todo(action.value)]);
  } else if (action is ToggleTodo) {
    return AppState.updateState(state,
        todos: state.todos
            .asMap()
            .map((index, todo) {
              if (index == action.value) {
                return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
              }
              return MapEntry(index, todo);
            })
            .values
            .toList());
  } else {
    return state;
  }
}
```

Is there a way to make it easier to comprehend? it seems like
`todos` and `visibilityFilter` are updated completely
independently. Sometimes state fields depend on one another
and more consideration is required, but in our case we can
easily split updating `todos` into a separate function:

```dart
List<Todo> todosReducer(List<Todo> todos, action) {
  if (action is AddTodo) {
    return [...todos, Todo(action.value)];
  } else if (action is ToggleTodo) {
    return todos
        .asMap()
        .map((index, todo) {
          if (index == action.value) {
            return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
          }
          return MapEntry(index, todo);
        })
        .values
        .toList();
  } else {
    return todos;
  }
}
```

Note that `todosReducer` accepts `todos`, the list of todos!
Now `appStateReducer` gives `todosReducer` just a slice of the
state to manage, and `todosReducer` knows how to update just
that slice.
**This is called *reducer composition*, and it's the fundamental
pattern of building Redux apps**.

Let's explore reducer composition more. Can we also extract
a reducer managing just `visibilityFilter`? We can.

```dart
VisibilityFilter visibilityFilterReducer(VisibilityFilter visibilityFilter, Action action) {
  if (action is SetVisibilityFilter) {
    return action.value;
  } else {
    return visibilityFilter;
  }
}
```

Now we can rewrite the main reducer as a function that calls
the reducers managing parts of the state, and combines them into
a single object.

```dart
List<Todo> todosReducer(List<Todo> todos, action) {
  if (action is AddTodo) {
    return [...todos, Todo(action.value)];
  } else if (action is ToggleTodo) {
    return todos
        .asMap()
        .map((index, todo) {
          if (index == action.value) {
            return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
          }
          return MapEntry(index, todo);
        })
        .values
        .toList();
  } else {
    return todos;
  }
}

VisibilityFilter visibilityFilterReducer(VisibilityFilter visibilityFilter, Action action) {
  if (action is SetVisibilityFilter) {
    return action.value;
  } else {
    return visibilityFilter;
  }
}

AppState appStateReducer(AppState state, dynamic action) => AppState(
      visibilityFilter: visibilityFilterReducer(state.visibilityFilter, action),
      todos: todosReducer(state.todos, action),
    );
```

**Note that each reducers is manging its own part of the global
state. The first parameter is different for every reducer, and
corresponds to the part of the state it manages.**

This is already looking good! When the app is larger, we can
split the reducers into seperate files and keep them
completely independent and managing different data domains.

### Going Further

Some readers might see that we can actually break down our
`itemReducer` into smaller functions! While it's quite
simple now, if we begin to add more and more actions, it might
get a bit confusing.

The power of function composition is that it can go infinitely
deep! We can continue to create smaller and smaller reducers
and compose them together in more complex functions.

In addition, by splitting up our Reducers, we can guarantee
type-safety in the smaller functions by checking & casting the Action
before we call the smaller reducer function.

Let's take a look at how to do just that!

```dart
List<Todo> addTodoReducer(List<Todo> todos, AddTodo action) {
  return [...todos, Todo(action.value)];
}

List<Todo> toggleTodoReducer(List<Todo> todos, ToggleTodo action) {
  return todos
      .asMap()
      .map((index, todo) {
        if (index == action.value) {
          return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
        }
        return MapEntry(index, todo);
      })
      .values
      .toList();
}

List<Todo> todosReducer(List<Todo> todos, action) {
  if (action is AddTodo) {
    return addTodoReducer(todos, action);
  } else if (action is ToggleTodo) {
    return toggleTodoReducer(todos, action);
  } else {
    return todos;
  }
}
```

### Reducing Boilerplate in a Type Safe Way

Now that we know how to compose (combine) reducers,
we can look at some utilties Redux provides to help
make this process easier.

We'll focus on two utilities included with Redux:
[`combineReducers()`](https://pub.dev/documentation/redux/latest/redux/combineReducers.html)
and 
[`TypedReducer`](https://pub.dev/documentation/redux/latest/redux/TypedReducer-class.html)

In this example, our `todosReducer` will be created by the
`combineReducers` function. Instead of checking for
each type of action and calling it manually, we
can setup a list of `TypeReducer`s.

```dart
Reducer<List<Todo>> todosReducer = combineReducers<List<Todo>>([
  TypedReducer<List<Todo>, AddTodo>(addTodoReducer),
  TypedReducer<List<Todo>, ToggleTodo>(toggleTodoReducer),
]);
```

### Source Code

`lib/src/reducer.dart`
```dart
import 'package:redux/redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';

class Todo {
  String text;
  bool completed;

  Todo(this.text) : completed = false;

  Todo.updateState(Todo oldTodo, {String text, bool completed})
      : text = text ?? oldTodo.text,
        completed = completed ?? oldTodo.completed;
}

class AppState {
  VisibilityFilter visibilityFilter;
  List<Todo> todos;

  AppState({this.visibilityFilter, this.todos});

  AppState.emptyState()
      : visibilityFilter = VisibilityFilter.showAll,
        todos = [];

  AppState.updateState(AppState oldState, {VisibilityFilter visibilityFilter, List<Todo> todos})
      : visibilityFilter = visibilityFilter ?? oldState.visibilityFilter,
        todos = todos ?? oldState.todos;
}

List<Todo> addTodoReducer(List<Todo> todos, AddTodo action) {
  return [...todos, Todo(action.value)];
}

List<Todo> toggleTodoReducer(List<Todo> todos, ToggleTodo action) {
  return todos
      .asMap()
      .map((index, todo) {
        if (index == action.value) {
          return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
        }
        return MapEntry(index, todo);
      })
      .values
      .toList();
}

Reducer<List<Todo>> todosReducer = combineReducers<List<Todo>>([
  TypedReducer<List<Todo>, AddTodo>(addTodoReducer),
  TypedReducer<List<Todo>, ToggleTodo>(toggleTodoReducer),
]);

VisibilityFilter visibilityFilterReducer(VisibilityFilter visibilityFilter, Action action) {
  if (action is SetVisibilityFilter) {
    return action.value;
  } else {
    return visibilityFilter;
  }
}

AppState appStateReducer(AppState state, dynamic action) => AppState(
      visibilityFilter: visibilityFilterReducer(state.visibilityFilter, action),
      todos: todosReducer(state.todos, action),
    );
```

### Next Steps
Next, we'll explore how to [create a Redux store](#store) that
holds the state and takes care of calling your reducer when you
dispatch an action.

## Store
In the previous sections, we defined the [actions](#actions) that
represent the facts about "what happened" and the
[reducers](#reducers) that update the state according to those
actions.

The **Store** is the object that brings them together. The store
has the following responsibilities:

* Holds application state;
* Allows access to state via [`state`](https://pub.dev/documentation/redux/latest/redux/Store/state.html)
* Allows state to be updated via [`dispatch(action)`](https://pub.dev/documentation/redux/latest/redux/Store/dispatch.html)
* Registers listeners via [`onChange.listen(listener)`](https://pub.dev/documentation/redux/latest/redux/Store/onChange.html)
* Handles unregistering of listeners the function
returned by [`onChange.listen(listener)`](https://pub.dev/documentation/redux/latest/redux/Store/onChange.html)

It's important to note that you'll only have a single store
in a Redux application. When you want to split your data handling
logic, you use [reducer composition](#splitting-reducers)
instead of many stores.

It's easy to create a store if you have a reducer. In the
[previous section](#reducers), we used
[`combineReducers()`](#https://pub.dev/documentation/redux/latest/redux/combineReducers.html)
to combine several reducers into one. We will now import it,
and pass it to [`Store()`](https://pub.dev/documentation/redux/latest/redux/Store/Store.html)

```dart
import 'package:redux/redux.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

Store store = Store<AppState>(appStateReducer, initialState: AppState.emptyState());
```

You man optionally specify the initial state as the second
argument to `createStore()`. This is useful for hydrating
the state of the client to match the state of the Redux
application running on the server.

```dart
Store store = Store<AppState>(appStateReducer, initialState: stateFromServer());
```

### Dispatching Actions

Now that we have created a store, let's verify our program
works! Even without any UI, we can already test the
update logic.

```dart
void main() {
  // Log the initial state
  print(store.state);

  // Every time the state changes, log it
  // Note that listen() returns an StreamSubscription for
  // unregistering the listener
  final subscription = store.onChange.listen(print);

  // Dispatch some actions
  store.dispatch(AddTodo('Learn about actions'));
  store.dispatch(AddTodo('Learn about reducers'));
  store.dispatch(AddTodo('Learn about store'));
  store.dispatch(ToggleTodo(0));
  store.dispatch(ToggleTodo(1));
  store.dispatch(SetVisibilityFilter(VisibilityFilter.showCompleted));

  // Stop listening to state updates
  subscription.cancel();
}
```

You can see how this causes the state held by the store to change:
(Note that because of the order that functions run in, the
line `subscription.cancel();` needs to be commented out to
get the resulting code). I have not fully understood why this
is the case yet.)

```
AppState {visibleTodoFilter: VisibilityFilter.showAll, todos: []}
AppState {visibleTodoFilter: VisibilityFilter.showAll, todos: [Todo {completed: false, text: "Learn about actions"}]}
AppState {visibleTodoFilter: VisibilityFilter.showAll, todos: [Todo {completed: false, text: "Learn about actions"}, Todo {completed: false, text: "Learn about reducers"}]}
AppState {visibleTodoFilter: VisibilityFilter.showAll, todos: [Todo {completed: false, text: "Learn about actions"}, Todo {completed: false, text: "Learn about reducers"}, Todo {completed: false, text: "Learn about store"}]}
AppState {visibleTodoFilter: VisibilityFilter.showAll, todos: [Todo {completed: true, text: "Learn about actions"}, Todo {completed: false, text: "Learn about reducers"}, Todo {completed: false, text: "Learn about store"}]}
AppState {visibleTodoFilter: VisibilityFilter.showAll, todos: [Todo {completed: true, text: "Learn about actions"}, Todo {completed: true, text: "Learn about reducers"}, Todo {completed: false, text: "Learn about store"}]}
AppState {visibleTodoFilter: VisibilityFilter.showCompleted, todos: [Todo {completed: true, text: "Learn about actions"}, Todo {completed: true, text: "Learn about reducers"}, Todo {completed: false, text: "Learn about store"}]}
```

We specified the behavior of our app before we even started
writing the UI. We won't do this in the tutorial, but at this
point you can write tests for your reducers and action
creators. You won't need to mock anything because they
are just [pure](https://redux.js.org/introduction/three-principles#changes-are-made-with-pure-functions)
functions. Call them, and make assertions on what they
return.

### Source Code
`lib/src/store.dart`
```dart
import 'package:redux/redux.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

Store store = Store<AppState>(appStateReducer, initialState: AppState.emptyState());
```

### Next Steps

Before creating a UI for our todo app, we will take a detour
to see [how the data flows in a Redux application](#data-flow)

## Data Flow

Redux architecture revolves around a **strict unidirectional
data flow**.

This means that all data in an application follows the
same lifecycle pattern, making the logic of your app more
predictable and easier to understand. It also encourages
data normalization, so you don't end up with multiple,
independent copies of the same data that are unaware of
one another.

If you're still not convinced, read [Motivation](https://redux.js.org/introduction/motivation/)
and [The Case for Flux](https://medium.com/swlh/the-case-for-flux-379b7d1982c6?)
for compelling argument in favor of unidirectional data
flow. Although [Redux is not exactly Flux](https://redux.js.org/introduction/prior-art/),
it shares the same key benefits.

The data lifecycle is any Redux app follows these 4 steps:

1. **You call** [`store.dispatch(action)`](https://pub.dev/documentation/redux/latest/redux/Store/dispatch.html).

An [action](#action) is a plain object describing *what happened.*
For example:

```
{ type: 'LIKE_ARTICLE', articleId: 42 }
{ type: 'FETCH_USER_SUCCESS', response: { id: 3, name: 'Mary' } }
{ type: 'ADD_TODO', text: 'Read the Redux docs.' }
```

Think of an action as a very brief snippet of news.
"Mary liked article 42." or "Read the Redux docs." was added
to the list of todos."

You can call [`store.dispatch(action)`](https://pub.dev/documentation/redux/latest/redux/Store/dispatch.html)
from anywhere in your app, including components and
XHR callbacks, or even at scheduled intervals.

2. **The Redux store calls the reducer function you gave it.**

The [store](#store) will pass two arguments to the [reducer](#reducers):
the current state tree and the action. For example, in the
todo app, the root reducer might receive something like this:

```dart
  // The current application state (list of todos and chosen filter)
  var previousState = AppState(visibilityFilter: VisibilityFilter.showAll, todos: [Todo('Read the docs.')]);

  // The action being performed (adding a todo).
  var action = AddTodo('Understand the flow.');

  // Your reducer returns the next application state.
  var nextState = appStateReducer(previousState, action);
```

Note that a reducer is a pure function. It only *computes*
the next state. It should be completely predictable: calling
it with the same inputs many times should produce the
same outputs. It shouldn't perform any side effects like API
calls or router transitions. These shoudl happen before
an action is dispatched.

3. **The root reducer may combine the output of multiple
reducers into a single state tree.**

How you structure the root reducer is completely up to you.
Redux ships with a [`combineReducers()`](https://pub.dev/documentation/redux/latest/redux/combineReducers.html)
helper function, useful for "splitting" the root reducer
into seperate functions taht each manage one branch of the
state tree.

Here's how `combineReducer()` works. Let's say you have
two reducers, one for handling `AddTodo` and another for
handling `ToggleTodo`

```dart
List<Todo> addTodoReducer(List<Todo> todos, AddTodo action) {
  // Somehow calculate it...
  return nextTodo
}

List<Todo> toggleTodoReducer(List<Todo> todos, ToggleTodo action) {
  // Somehow calculate it...
  return nextTodo
}

Reducer<List<Todo>> todosReducer = combineReducers<List<Todo>>([
  TypedReducer<List<Todo>, AddTodo>(addTodoReducer),
  TypedReducer<List<Todo>, ToggleTodo>(toggleTodoReducer),
]);
```

When you emit an action, `todosReducer` returned by
`combineReducers` will call both reducers:

```dart
var nextTodos = todos
nextTodos = addTodoReducer(nextTodos, action);
nextTodos = toggleTodoReducer(nextTodos, action);
```

It then returns the result:
```dart
return nextTodos;
```

While [`combineReeucers()`](https://pub.dev/documentation/redux/latest/redux/combineReducers.html)
is a handy helper utility, you don't have to use it; feel
free to write your own root reducer!

4. **The Redux store saves the complete state tree returned
by the root reducer.**

The new tree is now the next state of your app! Every listener
registered with [`store.onChange.listen(listener)`](https://pub.dev/documentation/redux/latest/redux/Store/onChange.html)
will now be invoked; listeners may call
[`store.state`](https://pub.dev/documentation/redux/latest/redux/Store/state.html)
to get the current state.

Now, the UI can be updated to reflect the new state.
If you use bindings like
[OverReact Redux](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md),
this is the point at which
`component.setState(newState)` is called.

### Next Steps

Now that you know how Redux works, let's
[connect it to a OverReact app](#usage-with-overreact).

> **Note for Advanced Users**
>
> If you're already familiar with the basic concepts and
have completed this tutorial, don't forget to check out
[async flow](https://github.com/johnpryan/redux.dart/blob/master/doc/async.md) in the [advanced tutorial](https://github.com/johnpryan/redux.dart/blob/master/doc/async.md) to learn
how middleware transforms [async actions](https://github.com/johnpryan/redux.dart/blob/master/doc/async.md) before they
reach the reducer.

## Usage with OverReact

From the very beginning, we need to stress that Redux has
no relation to OverReact. You can write Redux apps with
OverReact, AngularDart, or plain Dart.

That said, Redux works especially well with libraries
like [OverReact](https://github.com/Workiva/over_react)
because they let you describe UI as a function of state,
and Redux emits state updates in response to actions.

We will use React to build our simple todo app, and
cover the basics of how to use React with Redux.

> **Note**: see **the official OverReact Redux docs at
[https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md)**

### Installing OverReact Redux
[React bindings](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md)
are not included in Redux by default. You need to install
them explicitly:

Add the `over_react` package as a dependency in your `pubspec.yaml`.
```yaml
dependencies:
  redux: ^3.0.0
  over_react: '^3.1.0'
```
> **Note**: At the time of this writing, `over_react >= 3.1.0` depends on `redux ^3.0.0`
so `redux ^4.0.0` is incompatible.

Then run `pub get`.

### Presentational and Container Components

OverReact bindings for Redux seperate presentational
components from *container* components. This approach can make
your app easier to understand and allow you to more easily
reuse components. Here's a summary of the differences between
presentational and container components
(but if you're unfamiliar, we recommend that you also
read [Dan Abramov's original article describing the
concept of presentational and container
components](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0)):

|                | **Presentational Components**    | **Container Components**                       |
|----------------|----------------------------------|------------------------------------------------|
| Purpose        | How things look (markup, styles) | How things work (data fetching, state updates) |
| Aware of Redux | No                               | Yes                                            |
| To read data   | Read data from props             | Subscribe to Redux state                       |
| To change data | Invoke callbacks from props      | Dispatch Redux actions                         |
| Are written    | By hand                          | Usually generated by OverReact Redux           |

Most of the components we'll write will be presentational, but
we'll need to genereate a few container components to connect
them to the Redux store. This and the design brief below do
not imply container components must be near the top of the
component tree. If a container component becomes too complex
(i.e. it has heavily nested presentational components
with countless callbacks being passed down), introduce
another container within the component tree as noted in the
[FAQ](https://redux.js.org/faq/react-redux/#should-i-only-connect-my-top-component-or-can-i-connect-multiple-components-in-my-tree).

Technically you could write the container components by hand
using [`store.onChange.listen()`](https://pub.dev/documentation/redux/latest/redux/Store/onChange.html).
We don't advise you to do this because OverReact Redux makes many
performance optimizations that are hard to do by hand.
For this reason, rather than write container components,
we will generate them using the [`connect()`](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md#connect-parameters)
function provided by OverReact Redux, as you will see below.

### Designing Component Hiearchy

Remember how we
[designed the shape of the root state object](#reducers)?
It's time we design the UI hierarchy to match it.
This is not a Redux-specific task.
[Thinking in React](https://facebook.github.io/react/docs/thinking-in-react.html)
is a great tutorial that explains the process.

Our design brief is simple.
We want to show a list of todo items.
On clic, a todo item is crossed out as completed. We want to
show a field where the user may add a new todo. In the footer,
we want to show a toggle to show all, only completed, or
only active todos.

#### Designing Presentational Components

I see the following presentational components and their
props emerge from this brief:

* __`TodoList`__ is a list showing visible todos.
  * `List<Todo> todos` is an array of todo items with
  `{ text, completed }` shape.
  * `onTodoClick(int index)` is a callback to invoke when
  a todo is clicked.
* __`TodoListItem`__ is a single todo item.
  * `String text` is the text to show.
  * `bool completed` is whether the todo should appear
  crossed out.
  * `toggleTodo()` is a callback to invoke when the link is clicked.
* __`Link`__ is a link with a callback.
  * `bool active` is whether the button should be disabled.
  * `VisibilityFilter filter` is the visibility filter it represents. (Note: this is used for container component)
  * `setVisibilityFilter()` is a callback to invoke when the link is clicked.
* __`Footer`__ is where we let the user change currently visible
todos.
* __`App`__ is the root component that renders everything else.

They describe the *look* but don't know *where* the data
comes from, or *how* to change it. They only render what's
given to them. If you migrate from Redux to something else,
you'll be able to keep all these components exactly the same.
They have no dependency on Redux.

#### Designing Container Components

We will also need some container components to connect the
presentational components to Redux. For example, the
presentational `TodoList` component needs a container like
`ConnectedTodoList` that subscribes to the Redux store
and knows how to apply the current visibility filter.
To change the visibility filter, we will provide a
`ConnectedLink` container component that renders a
`Link` that dispatches an appropriate action on click:

* __`ConnectedTodoList`__ filters the todos according to the current
visibility filter and renders a `TodoList`.

* __`ConnectedLink`__ gets the current visibility filter and renders
a `Link`.
  * `VisibilityFilter filter` is the visibility filter it represents.

#### Designing Other Components

Sometimes it's hard to tell if some component should be
presentational component or a container. For example, sometimes
form and function are really coupled together, such as the case
of this tiny component:

* __`ConnectedAddTodoInput`__ provides the dispatch function
* __`AddTodoInput`__ is an input field with "Add" button

Technically we could split two components so
that `AddTodoInput` is not aware of Redux,
 but it might be too early
at this stage. It's fine to mix presentation and logic in a component
that is very small. As it grows, it will be more obvious
how to split it, so we'll leave it mixed.

### Implementing Components
Let's write the components! We begin with the presentational
components so we don't need to think about binding to
Redux yet.

#### Implementing Presentational Components

These are all normal OverReact components, so we won't examine
them in detail. We write stateless components
unless we need to use local state or the lifecycle methods.

`lib/src/components/todo_list_item.dart`
```dart
import 'package:over_react/over_react.dart';

part 'todo_list_item.over_react.g.dart';

@Factory()
UiFactory<TodoListItemProps> TodoListItem = _$TodoListItem;

@Props()
class _$TodoListItemProps extends UiProps {
  void Function() toggleTodo;
  bool completed;
  String text;
}

@Component2()
class TodoListItemComponent extends UiComponent2<TodoListItemProps> {
  @override
  dynamic render() {
    return (Dom.li()
      ..style = {'textDecoration': props.completed ? 'line-through' : 'none'}
      ..onClick = (_) {
        props.toggleTodo();
      })(
      '${props.text}',
    );
  }
}
```

`lib/src/components/todo_list.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list_item.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'todo_list.over_react.g.dart';

@Factory()
UiFactory<TodoListProps> TodoList = _$TodoList;

@Props()
class _$TodoListProps extends UiProps {
  List<Todo> todos;
  void Function(int index) onTodoClick;
}

@Component2()
class TodoListComponent extends UiComponent2<TodoListProps> {
  @override
  dynamic render() {
    Dom.ul()(props.todos
        .asMap()
        .map((index, todo) => (MapEntry(
            index,
            (TodoListItem()
              ..key = index
              ..completed = todo.completed
              ..text = todo.text
              ..toggleTodo = () => props.onTodoClick(index))())))
        .values
        .toList());
  }
}
```

`lib/src/components/link.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'link.over_react.g.dart';

@Factory()
UiFactory<LinkProps> Link = _$Link;

@Props()
class _$LinkProps extends UiProps {
  bool active;
  VisibilityFilter filter;
  void Function() setVisibilityFilter;
}

@Component2()
class LinkComponent extends UiComponent2<LinkProps> {
  @override
  dynamic render() {
    return (Dom.button()
      ..style = {'marginLeft': '4px'}
      ..disabled = props.active
      ..onClick = (e) {
        e.preventDefault();
        props.setVisibilityFilter();
      })(
      props.children,
    );
  }
}
```

`lib/src/components/footer.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/components/link.dart';

part 'footer.over_react.g.dart';

@Factory()
UiFactory<FooterProps> Footer = _$Footer;

@Props()
class _$FooterProps extends UiProps {}

@Component2()
class FooterComponent extends UiComponent2<FooterProps> {
  @override
  dynamic render() {
    return Dom.p()(
      'Show: ',
      (ConnectedLink()..filter = VisibilityFilter.showAll)(
        'All',
      ),
      (ConnectedLink()..filter = VisibilityFilter.showActive)(
        'Active',
      ),
      (ConnectedLink()..filter = VisibilityFilter.showCompleted)(
        'Completed',
      ),
    );
  }
}
```

#### Implementing Container Components

Now it's time to hook up those presentational components to
Redux by creating some containers. Technically, a container
component is just a React component that uses
[`store.onChange.listen()`](https://pub.dev/documentation/redux/latest/redux/Store/onChange.html)
to read part of the Redux state tree and supply props to a
presentational component it renders. You could write a container
component by hand, but we suggest instead generating
container components with OverReact Redux library's
[`connect()`](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md#connect)
function, which provides many useful optimizations to
prevent unncecessary re-renders. (One result of this is that
you shouldn't have to worry about the 
[React performance suggestion](https://reactjs.org/docs/optimizing-performance.html)
of implementing `shouldComponentUpdate` youself.)

To use `connect()`, you need to define a special function called
`mapStateToProps` that describe how to transform the current
Redux store into the props you want to pass to a presentational
component you are wrapping. For example,
`VisibleTodoList` needs to calculate `todos` to pass to the
`TodoList`, so we define a function that filters the
`state.todos` according to the `state.visibilityFilter`, and
use it in its `mapStateToProps`.

```dart
List<Todo> getVisibleTodos(List<Todo> todos, VisibilityFilter filter) {
  if (filter == VisibilityFilter.showCompleted) {
    return todos.where((todo) => todo.completed).toList();
  } else if (filter == VisibilityFilter.showActive) {
    return todos.where((todo) => !todo.completed).toList();
  } else {
    return todos;
  }
}

TodoListProps mapStateToProps(AppState state) {
  return TodoList()..todos = getVisibleTodos(state.todos, state.visibilityFilter);
}
```

In addtion to reading the state, container components can
dispatch actions. In a similar fashion, you can define a function
called `mapDispatchToProps()` that receives the
[`dispatch()`](https://pub.dev/documentation/redux/latest/redux/Store/dispatch.html)
method and returns callback props that you want to inject
into the presentational component.
For example, we want the `ConnectedTodoList` to inject a prop
called `onTodoClick` into the `TodoList` component,
and we want `onTodoClick` to dispatch a `ToggleTodo` action:

```dart
TodoListProps mapDispatchToProps(dynamic Function(dynamic) dispatch) {
  return TodoList()..onTodoClick = (index) => dispatch(ToggleTodo(index));
}
```

Finally, we create the `VisibleTodoList` by calling `connect()`
and passing these two functions:

```dart
import 'package:over_react/over_react_redux.dart';

UiFactory<TodoListProps> ConnectedTodoList = connect<AppState, TodoListProps>(
  mapDispatchToProps: mapDispatchToProps,
  mapStateToProps: mapStateToProps,
)(TodoList);
```

These are the basics of the OverReact Redux API, but there
are a few shortcuts and power options so we encourage you to
check out [its documentation](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md)
in detail. In case you are worried about
`mapStateToProps` creating new objects too often,
you might want to learn about
[computing derived data](https://redux.js.org/recipes/computing-derived-data)
with
[reselect](https://pub.dev/packages/reselect).

Find the rest of the container components defined below:
(Note that we are appending code to the files we had
for the presentational components earlier).

`lib/src/components/link.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'link.over_react.g.dart';

@Factory()
UiFactory<LinkProps> Link = _$Link;

@Props()
class _$LinkProps extends UiProps {
  bool active;
  VisibilityFilter filter;
  void Function() setVisibilityFilter;
}

@Component2()
class LinkComponent extends UiComponent2<LinkProps> {
  @override
  dynamic render() {
    return (Dom.button()
      ..style = {'marginLeft': '4px'}
      ..disabled = props.active
      ..onClick = (e) {
        e.preventDefault();
        props.setVisibilityFilter();
      })(
      props.children,
    );
  }
}

LinkProps mapStateToPropsWithOwnProps(AppState state, LinkProps ownProps) {
  return Link()..active = state.visibilityFilter == ownProps.filter;
}

LinkProps mapDispatchToPropsWithOwnProps(dynamic Function(dynamic) dispatch, LinkProps ownProps) {
  return Link()..setVisibilityFilter = () => dispatch(SetVisibilityFilter(ownProps.filter));
}

UiFactory<LinkProps> ConnectedLink = connect<AppState, LinkProps>(
  mapStateToPropsWithOwnProps: mapStateToPropsWithOwnProps,
  mapDispatchToPropsWithOwnProps: mapDispatchToPropsWithOwnProps,
)(Link);
```

`lib/src/components/todo_list.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list_item.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'todo_list.over_react.g.dart';

@Factory()
UiFactory<TodoListProps> TodoList = _$TodoList;

@Props()
class _$TodoListProps extends UiProps {
  List<Todo> todos;
  void Function(int index) onTodoClick;
}

@Component2()
class TodoListComponent extends UiComponent2<TodoListProps> {
  @override
  dynamic render() {
    var children = props.todos
        .asMap()
        .map((index, todo) => (MapEntry(
            index,
            (TodoListItem()
              ..key = index
              ..completed = todo.completed
              ..text = todo.text
              ..toggleTodo = () => props.onTodoClick(index))())))
        .values
        .toList();

    return Dom.ul()(children);
  }
}

List<Todo> getVisibleTodos(List<Todo> todos, VisibilityFilter filter) {
  if (filter == VisibilityFilter.showCompleted) {
    return todos.where((todo) => todo.completed).toList();
  } else if (filter == VisibilityFilter.showActive) {
    return todos.where((todo) => !todo.completed).toList();
  } else {
    return todos;
  }
}

TodoListProps mapStateToProps(AppState state) {
  return TodoList()..todos = getVisibleTodos(state.todos, state.visibilityFilter);
}

TodoListProps mapDispatchToProps(dynamic Function(dynamic) dispatch) {
  return TodoList()..onTodoClick = (index) => dispatch(ToggleTodo(index));
}

UiFactory<TodoListProps> ConnectedTodoList = connect<AppState, TodoListProps>(
  mapDispatchToProps: mapDispatchToProps,
  mapStateToProps: mapStateToProps,
)(TodoList);
```

#### Implementing Other Components

`lib/src/components/add_todo.dart`

Recall as [mentioned previously](#designing-other-components), both the presentation and logic
`AddTodoInput` component are mixed into a single definition,
with `ConnectedAddTodoInput` providing a thin wrapper.
Because we need access to `props.dispatch` function,
we need to add the `ConnectPropsMixin` to the prop
class.

```dart
import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'add_todo_input.over_react.g.dart';

@Factory()
UiFactory<AddTodoInputProps> AddTodoInput = _$AddTodoInput;

@Props()
class _$AddTodoInputProps extends UiProps with ConnectPropsMixin {
  // dynamic Function(dynamic) dispatch;
}

@Component2()
class AddTodoInputComponent extends UiComponent2<AddTodoInputProps> {
  @override
  dynamic render() {
    var input;
    return (Dom.div()(
      (Dom.form()
            ..onSubmit = (e) {
              e.preventDefault();
              if (input.value.trim() == '') {
                return;
              }
              props.dispatch(AddTodo(input.value));
              input.value = '';
            })(
          (Dom.input()
            ..ref = (InputElement node) {
              input = node;
            })(),
          (Dom.button()..type = 'submit')(
            'Add Todo',
          )),
    ));
  }
}

UiFactory<AddTodoInputProps> ConnectedAddTodoInput = connect<AppState, AddTodoInputProps>()(AddTodoInput);
```

If you are unfamiliar with the `ref` attribute, please
read this [documentation](https://facebook.github.io/react/docs/refs-and-the-dom.html)
to familiarze yourself with the recommended use
of this attribute.

#### Tying the containers together within a component

`lib/src/components/app.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/components/add_todo_input.dart';
import 'package:redux_dart_basic_tutorial/src/components/footer.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list.dart';
part 'app.over_react.g.dart';

@Factory()
UiFactory<AppProps> App = _$App;

@Props()
class _$AppProps extends UiProps {}

@Component2()
class AppComponent extends UiComponent2<AppProps> {
  @override
  dynamic render() {
    return Dom.div()(
      ConnectedAddTodoInput()(),
      ConnectedTodoList()(),
      Footer()(),
    );
  }
}
```

#### Creating the package

Expose the `App` component and Redux `store`.

`lib/redux_dart_basic_tutorial.dart`
```dart
library redux_dart_basic_tutorial;

export 'package:redux_dart_basic_tutorial/src/components/app.dart' show App;
export 'package:redux_dart_basic_tutorial/src/store.dart' show store;
```
### Passing the Store

All container components need access to the Redux store so they
can subscribe to it. One option would be to pass it as a prop
to every container component. However, it gets tedious, as you
have to wire `store` even through presentational components
just because they happen to render a container deep in the
component tree.

The option we recommend is to use a special OverReact Redux
component called [`ReduxProvider`](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md#reduxprovider)
to [magically](https://reactjs.org/docs/context.html) make the store available to all container
components in the application without passing it explicitly.
You only need to use it once when you render
the root component:

`web/main.dart`
```dart
import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:over_react/react_dom.dart' as react_dom;

import 'package:redux_dart_basic_tutorial/redux_dart_basic_tutorial.dart';

void main() {
  setClientConfiguration();

  final output = querySelector('#output');

  final app = (ReduxProvider()..store = store)(
    App()(),
  );

  react_dom.render(app, output);
}
```

### Next Steps

Read the [complete source code for this tutorial](#example-todo-list) to
better internalize the knowledge you have gained. Then, head
straight to the [advanced tutorial](https://github.com/johnpryan/redux.dart/blob/master/doc/async.md)
to learn how to handle network requests and routing!

You should also take some time to [**read through the
OverReact Redux docs**](https://github.com/Workiva/over_react/blob/master/doc/over_react_redux_documentation.md)
to get a better understanding of how to use OverReact and
Redux together.

## Example: Todo List

This is the complete source code of the tiny todo app we built
during the [basics tutorial](#basics).

### Entry Point

`web/main.dart`
```dart
import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:over_react/react_dom.dart' as react_dom;

import 'package:redux_dart_basic_tutorial/redux_dart_basic_tutorial.dart';

void main() {
  setClientConfiguration();

  final output = querySelector('#output');

  final app = (ReduxProvider()..store = store)(
    App()(),
  );

  react_dom.render(app, output);
}
```

### Actions

`lib/src/actions.dart`
```dart
class Action {
  Action({this.type, this.value});

  final String type;
  final dynamic value;
}

enum VisibilityFilter { showAll, showCompleted, showActive }

class AddTodo extends Action {
  AddTodo([String text]) : super(type: 'ADD_TODO', value: text);
}

class ToggleTodo extends Action {
  ToggleTodo([int index]) : super(type: 'TOGGLE_TODO', value: index);
}

class SetVisibilityFilter extends Action {
  SetVisibilityFilter([VisibilityFilter filter]) : super(type: 'SET_VISIBILITY_FILTER', value: filter);
}
```

### Reducers

`lib/src/reducers.dart`
```dart
import 'package:redux/redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';

class Todo {
  String text;
  bool completed;

  Todo(this.text) : completed = false;

  Todo.updateState(Todo oldTodo, {String text, bool completed})
      : text = text ?? oldTodo.text,
        completed = completed ?? oldTodo.completed;
}

class AppState {
  VisibilityFilter visibilityFilter;
  List<Todo> todos;

  AppState({this.visibilityFilter, this.todos});

  AppState.emptyState()
      : visibilityFilter = VisibilityFilter.showAll,
        todos = [];

  AppState.updateState(AppState oldState, {VisibilityFilter visibilityFilter, List<Todo> todos})
      : visibilityFilter = visibilityFilter ?? oldState.visibilityFilter,
        todos = todos ?? oldState.todos;
}

List<Todo> addTodoReducer(List<Todo> todos, AddTodo action) {
  return [...todos, Todo(action.value)];
}

List<Todo> toggleTodoReducer(List<Todo> todos, ToggleTodo action) {
  return todos
      .asMap()
      .map((index, todo) {
        if (index == action.value) {
          return MapEntry(index, Todo.updateState(todo, completed: !todo.completed));
        }
        return MapEntry(index, todo);
      })
      .values
      .toList();
}

Reducer<List<Todo>> todosReducer = combineReducers<List<Todo>>([
  TypedReducer<List<Todo>, AddTodo>(addTodoReducer),
  TypedReducer<List<Todo>, ToggleTodo>(toggleTodoReducer),
]);

VisibilityFilter visibilityFilterReducer(VisibilityFilter visibilityFilter, dynamic action) {
  if (action is SetVisibilityFilter) {
    return action.value;
  } else {
    return visibilityFilter;
  }
}

AppState appStateReducer(AppState state, dynamic action) => AppState(
      visibilityFilter: visibilityFilterReducer(state.visibilityFilter, action),
      todos: todosReducer(state.todos, action),
    );
```

### Components
`lib/src/components/todo_list_item.dart`
```dart
import 'package:over_react/over_react.dart';

part 'todo_list_item.over_react.g.dart';

@Factory()
UiFactory<TodoListItemProps> TodoListItem = _$TodoListItem;

@Props()
class _$TodoListItemProps extends UiProps {
  void Function() toggleTodo;
  bool completed;
  String text;
}

@Component2()
class TodoListItemComponent extends UiComponent2<TodoListItemProps> {
  @override
  dynamic render() {
    return (Dom.li()
      ..style = {'textDecoration': props.completed ? 'line-through' : 'none'}
      ..onClick = (_) {
        props.toggleTodo();
      })(
      '${props.text}',
    );
  }
}
```
`lib/src/components/todo_list.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list_item.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'todo_list.over_react.g.dart';

@Factory()
UiFactory<TodoListProps> TodoList = _$TodoList;

@Props()
class _$TodoListProps extends UiProps {
  List<Todo> todos;
  void Function(int index) onTodoClick;
}

@Component2()
class TodoListComponent extends UiComponent2<TodoListProps> {
  @override
  dynamic render() {
    var children = props.todos
        .asMap()
        .map((index, todo) => (MapEntry(
            index,
            (TodoListItem()
              ..key = index
              ..completed = todo.completed
              ..text = todo.text
              ..toggleTodo = () => props.onTodoClick(index))())))
        .values
        .toList();

    return Dom.ul()(children);
  }
}

List<Todo> getVisibleTodos(List<Todo> todos, VisibilityFilter filter) {
  if (filter == VisibilityFilter.showCompleted) {
    return todos.where((todo) => todo.completed).toList();
  } else if (filter == VisibilityFilter.showActive) {
    return todos.where((todo) => !todo.completed).toList();
  } else {
    return todos;
  }
}

TodoListProps mapStateToProps(AppState state) {
  return TodoList()..todos = getVisibleTodos(state.todos, state.visibilityFilter);
}

TodoListProps mapDispatchToProps(dynamic Function(dynamic) dispatch) {
  return TodoList()..onTodoClick = (index) => dispatch(ToggleTodo(index));
}

UiFactory<TodoListProps> ConnectedTodoList = connect<AppState, TodoListProps>(
  mapDispatchToProps: mapDispatchToProps,
  mapStateToProps: mapStateToProps,
)(TodoList);

```
`lib/src/components/link.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'link.over_react.g.dart';

@Factory()
UiFactory<LinkProps> Link = _$Link;

@Props()
class _$LinkProps extends UiProps {
  bool active;
  VisibilityFilter filter;
  void Function() setVisibilityFilter;
}

@Component2()
class LinkComponent extends UiComponent2<LinkProps> {
  @override
  dynamic render() {
    return (Dom.button()
      ..style = {'marginLeft': '4px'}
      ..disabled = props.active
      ..onClick = (e) {
        e.preventDefault();
        props.setVisibilityFilter();
      })(
      props.children,
    );
  }
}

LinkProps mapStateToPropsWithOwnProps(AppState state, LinkProps ownProps) {
  return Link()..active = state.visibilityFilter == ownProps.filter;
}

LinkProps mapDispatchToPropsWithOwnProps(dynamic Function(dynamic) dispatch, LinkProps ownProps) {
  return Link()..setVisibilityFilter = () => dispatch(SetVisibilityFilter(ownProps.filter));
}

UiFactory<LinkProps> ConnectedLink = connect<AppState, LinkProps>(
  mapStateToPropsWithOwnProps: mapStateToPropsWithOwnProps,
  mapDispatchToPropsWithOwnProps: mapDispatchToPropsWithOwnProps,
)(Link);
```

`lib/src/components/footer.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/components/link.dart';

part 'footer.over_react.g.dart';

@Factory()
UiFactory<FooterProps> Footer = _$Footer;

@Props()
class _$FooterProps extends UiProps {}

@Component2()
class FooterComponent extends UiComponent2<FooterProps> {
  @override
  dynamic render() {
    return Dom.p()(
      'Show: ',
      (ConnectedLink()..filter = VisibilityFilter.showAll)(
        'All',
      ),
      (ConnectedLink()..filter = VisibilityFilter.showActive)(
        'Active',
      ),
      (ConnectedLink()..filter = VisibilityFilter.showCompleted)(
        'Completed',
      ),
    );
  }
}

```
`lib/src/components/add_todo_input.dart`
```dart
import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';
import 'package:redux_dart_basic_tutorial/src/actions.dart';
import 'package:redux_dart_basic_tutorial/src/reducers.dart';

part 'add_todo_input.over_react.g.dart';

@Factory()
UiFactory<AddTodoInputProps> AddTodoInput = _$AddTodoInput;

@Props()
class _$AddTodoInputProps extends UiProps with ConnectPropsMixin {}

@Component2()
class AddTodoInputComponent extends UiComponent2<AddTodoInputProps> {
  @override
  dynamic render() {
    var input;
    return (Dom.div()(
      (Dom.form()
            ..onSubmit = (e) {
              e.preventDefault();
              if (input.value.trim() == '') {
                return;
              }
              props.dispatch(AddTodo(input.value));
              input.value = '';
            })(
          (Dom.input()
            ..ref = (InputElement node) {
              input = node;
            })(),
          (Dom.button()..type = 'submit')(
            'Add Todo',
          )),
    ));
  }
}

UiFactory<AddTodoInputProps> ConnectedAddTodoInput = connect<AppState, AddTodoInputProps>()(AddTodoInput);
```
`lib/src/components/app.dart`
```dart
import 'package:over_react/over_react.dart';
import 'package:redux_dart_basic_tutorial/src/components/add_todo_input.dart';
import 'package:redux_dart_basic_tutorial/src/components/footer.dart';
import 'package:redux_dart_basic_tutorial/src/components/todo_list.dart';
part 'app.over_react.g.dart';

@Factory()
UiFactory<AppProps> App = _$App;

@Props()
class _$AppProps extends UiProps {}

@Component2()
class AppComponent extends UiComponent2<AppProps> {
  @override
  dynamic render() {
    return Dom.div()(
      ConnectedAddTodoInput()(),
      ConnectedTodoList()(),
      Footer()(),
    );
  }
}
```
