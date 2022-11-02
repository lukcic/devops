# TypeScript
Any code valid in JS is also valid in TS.

`npm i -g typescript`
-g globally

tsc - typescript compiler
TypeScript code cannot work anywhere. Compiler is used to convert code into Vanila JS (ES3). ES3 doesn’t have async await.  ES5 by default.
`tsc index.ts`

`tsc  —watch index.ts`

`tsc —init` - will create default **tsconfig.json** file

tsconfig.json - settings for tsc compiler
```json
{
	"compilerOptions": {
		"target": "esnext",		// newest version of js with async
		"watch": true,	//recompile code every save
		"lib": ["dom", "es2017"], // native DOM classes (urls etc)
	}
}
```

“outDir” : “./dist” - root folder where JS files from compilation are stored
“rootDir”: ‘“./src” - where ts source code should be stored 

Folders:
src - for typescript files
dist - for JS (project files)

Types:
```
let lucky: number;
- - - - - - - - - - - - - - - - - - - - - -

let somenumber = 23; // this will create variable strongly typed as number

somenumber = '23' // this will return error
- - - - - - - - - - - - - - - - - - - - - -

let anothernumber: any = 23;	// create variable of type 'any'
othernumber = '23'		// this will not return error
```

Even if type isn’t set explicitly (using : typename) TypeScript will assign type using first value.

## Own types:
```ts
type Style = 'bold' | 'italic';  	// new type called Style with 2 possible options (can be different, not only strings)

let somefont: Style;		// new variable of type Style

```

```ts
#Schema of JS object
interface Person {
	first: string;
	last: string;
	#[key: string]: any			// optional property
}

const person: Person = {		// variable of type person
	first: 'Adam',
	last: 'Slodowy'
}

const person2: Person = {		// this will return error
	first: 'Usain',				// because too much properties
	last: 'Bolt',
	fast: true
}
```


## Types in arrays:
```ts
const arr: number[] = []

arr.push(1)	// ok
arr.push('23')	// return error

let employee: [number, string][]
employee = [
	[1, 'Brad'],
	[1, 'Tom'],
]
```

## Tuples (not available in JS):
```ts
type Mylist = [number, string, boolean?]	// ? means optionsl

const arr: MyList = []	// return error, tuple cannot be empty, must be provided with all parameters
```

## Unions:
Variable hold more than one type.

```ts
let id: string| number 
pid = 22
```

## Enums - enumerated type:
Allows to define a set o named constants either numeric or string.

```ts
enum Direction1 {
	Up,
	Down,
	Left,
	Right,
}

console.log(Direction1.Up)	// should return 0 - first index
```
First index can be changed.

```ts
enum Direction2 {
	Up = 'up',
	Down = 'down',
	Left = 'left',
	Right = 'right',
}

console.log(Direction2.Left)	// should return 'left'
```

## Objects
```ts
const user: {
	id: number,
	name: string
} = {
	id: '1',		// will return error, because of string
	name: 'John'
}

// different way:
type User = {
	id: number,
	name: string
}

const user: User = {	// create variable user of type User
	id: 1,	
	name: 'John'
}
```

## Type assertion
We want to treat entity as a different type.

```ts
let cid: any = 1

let customerId = <number>cid 	
// changing type of cid from any to numer to use as customerId 

customerId = true		// returns error - must be a number

// different way:

let customerID = cid as number
```

## Functions
```ts
function pow(x: number, y: number) {
	return Math.pow(x,y);	# natively will return number
}
pow(5,10)
```

```ts
function pow(x: number ,y: number): string {		// function will return string
	return Math.pow(x,y).toString();	
}
pow(5,10)
```

Type `void` is used when function doesn’t return any value (event listeners).

```ts
function log(message: string | number): void {
	console.log(message)
}

// this function will nor return any value
```

## Interface
Custom type. Specific structure to an object/function.

Interface cannot use unions - Type must be used.
```ts
interface UserInterface {
	readonly id: number,
	name: string
	age?: number	// optional
}

const user1: UserInterface = {
	id: 1,	
	name: 'John'
}

user1.id = 5	// return error, change id can't be done, because readonly
```

### Interfaces with functions
```ts
interface MathFunc {
	(x: number, y: number): number
}

const add: MathFunc = (x: number, y: number): number => x + y
// OK (=> arrow function )
const sub: MathFunc = (x: number, y: number): number => x - y


const add: MathFunc = (x: number, y: string): number => x + y
// will return error because do not match the interface
```

#### Arrow functions
The same as normal functions: remove word `function`, place arrow before body bracket. Remove braces and word return. Remove argument parenthesis;

```js
//Anonymouf function
(function (a) {
  return a + 100;
});

// remove 'function', add arrow
(a) => {
  return a + 100;
};

// remove the body braces and word "return" — the return is implied.
(a) => a + 100;

// remove the argument parentheses
a => a + 100;

```

## Classes
Form ES 6 in JS. Used for creating objects. Multiple objects using class.
Class have properties and methods (functions inside the class). 

```ts
class Person {
	id: number		// properties
	name: string
	
	// runs whenever an object is created from the class
	// constructor id and name thats nor class id and name
	constructor(id: number, name: string) {
		this.id = id
		this.name	= name
		console.log('Person creted.')
	}

	register() {
		return `${this.name} is now registered`
	}

}

const tom = new Person()		// run the constructor
const anna = new Person(1, 'Anna Nowak') // error without properties

console.log(anna.register())	// Anna Nowak is now registered.
```

this - the class we’re in: `this.id === Person.id`

### Data modifiers
Properties (class) as id and name are publicly available by default. From outside of class chan be changed.

**public** - default value, property is accessed from anywhere of code 

**private** - access only from class, read and change
`private id: number`
`tom.id =5` returns error
`console.log(tom.id)` - returns error

**protected** - access only from class, read and change and from class that extends this class
`protected id: number`
`tom.id =5` returns error
`console.log(tom.id)` - returns error

### Classes with interfaces

```ts
interface PersonInterface {
	id: number
	name: string
	register(): string
}

class Person implements PersonInterface {
	id: number
	name: string
	
	constructor(id: number, name: string) {
		this.id = id
		this.name	= name
	}

	register() {
		return `${this.name} is now registered`
	}
}

// Subclass
class Employee extends Person {
	position: string
	constructor(id: number, name: string, position: string) {
		super(id, name)		# will use connection from parent
		this.position = position
	}
}

const emp = new Employee(3, 'Shawn', 'developer')
console.log(emp.register())	
// will use register method from parent class
```

## Generics:
Used to build re-usable components. 

```ts
// this function will get array of items and return new array (of any tpye) with concatinated array from input

function getArray(items: any[]): any[] {
	return new Array().concat(items) //JS functions
}

let numArray = getArray([1,2,3,4])
let strArray = getArray(['brad','john','joe'])

numArray.push('hello')
// no error, because 'getArray' use any as input
```

The same with Generics:
```ts
function getArray<T>(items: T[]): T[] {
	return new Array().concat(items) //T - type
}

let numArray = getArray<number>([1,2,3,4])
let strArray = getArray<string>(['brad','john','joe'])

numArray.push('hello')
// returns error, because 'getArray' use definied type
```

T is a place-holdrer for a type.

```ts
# Observable - class that has an internal value that you can observe

class Observable<T> {		# T represents a variable type that we can pass in to strong type this observables internal value
	constructor(public value: T) {}
}

let x: Observable<number>;
let y: Observable<Person>;
let z = new Observable(23)
```

For using types internally inside class or a function

## TS with React

`npx create-react-app . --template typescript`	- initialization of react
`npm start`	- start the app

```tsx

export interface Props {
	title: string
	color?: string
}

const Header = (props: Props) => {
	return (
		<header>
			<h1 style={{color: props.color ? props.color: 'blue'}}>{props.title}</h1>
		</header>
		)
}

export default Header
```

`<h1 style={{}}>` - inline styling of h1
`color: props.color ? props.color: 'blue'` - check if `props.color` exists and use it; if not use blue


In app:
```tsx
import Header form './Header'	 //Header.tsx

function App() {
	return (
		<div className='App'>
			<Header title='Hello World' color='red'/>
		</div>
	)
}

export default App
```

prop types???

