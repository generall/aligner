aligner
=======

Sublime Text plugin for automatic code aligment.

This project is a tool for automatic code alignment. 
As is known to improve readability is often used formatting source code so that similar syntactic structures are arranged one above the other.

First of all, for convenience, the lines of code are split into tokens having a generic type.
For example, the identifiers have type `:id`, and the brackets have type `:bracket`.
The project implemented a type hierarchy, which simplifies the setup.
It is defined in `heirarchy.rb`.


Each type must match the regular expression that recognizes token of this type.
Moreover, the sequence of regular expressions must follow the hierarchy.
That is more general regular expressions are used later.
This sequence is described in the class `TypeData`, the file `staff.rb`.


To achieve maximum flexibility and independence of the type of language in which the source code is written,
parser of the context-free grammars is implemented.

It works in conjunction with the algorithm based on dynamic programming,
which finds matching having a maximum weight of two arrays of tokens.

The grammar in BNF is in file `grammar.rb`.
Grammar should be designed so that if the rule of convolution can be applied,
it should be applied, otherwise any sequence of tokens should still be correct.

Here is the example of grammar:
```
@@grammar.add_rule(:main, [:expr    ], [:reducible]);
@@grammar.add_rule(:expr, [:expr, :p], [:reducible]);
@@grammar.add_rule(:expr, [:p       ], [:reducible]);
t1 = [:expr, TokenTemplate.new(['=']), :expr]
@@grammar.add_rule(:expr, t1)
@@grammar.add_rule(:p, [:t], [:reducible])
@@grammar.add_rule(:t, [TokenTemplate.new(:id)], [:reducible]);
```

This grammar defines the assignment operation.
The first argument to the procedure of adding rules - nonterminal. 
`:main` - axiom of the grammar.
The second argument is the rule itself. It may consist of nonterminals and templates of tokens.
A template can define a valid token type, a specific value, and excluded values.

Grammar shown corresponds to the following recorded in the canonical Backus–Naur form:

```
main ::= expr
expr ::= expr p | p | expr '=' expr
p    ::= t
t    ::= <any identifier>
```

Flag `:reducible` indicates that this rule has no effect on meta-expression being fitted.
Meta-expression is an array of tokens, which also contains other meta-expression.
Each level of the obtained tree structure is compared in the matching process only with the corresponding level of the other meta-expression.
Consider the example:
```
f(a, b + c   )
f(   b + c, a)
```
and
```
f(a    , b + c)
f(b + c, a    )
```
When using the grammar, the program causes the alignment of the second type,
in spite of the fact that different function arguments are similar in spelling.
Such behavior is, of course, leads to improvement of readability.

## Examples of work

From
```
@@types_inheritance[:space] = nil;
@@types_inheritance[:quote] = nil;
@@types_inheritance[:regexp] = nil;
@@types_inheritance[:id] = nil;
@@types_inheritance[:spchar] = nil;
```

To

```
@@types_inheritance[:space ] = nil;
@@types_inheritance[:quote ] = nil;
@@types_inheritance[:regexp] = nil;
@@types_inheritance[:id    ] = nil;
@@types_inheritance[:spchar] = nil;
```
---

From
```
switch (state)                                
{                                            
    case State.QLD: city = "Brisbane"; break; 
    case State.WA: city = "Perth"; break;     
    case State.NSW: city = "Sydney"; break;   
    default: city = "???"; break;             
}            
```

To

```
switch (state)                                
{
    case    State.QLD : city = "Brisbane"; break;
    case    State.WA  : city = "Perth"   ; break;
    case    State.NSW : city = "Sydney"  ; break;
    default           : city = "???"     ; break;
}                                            
```

##Learning

Due to the fact that different people are accustomed to different ways of setting padding between tokens,
you must use the simplest method of fine-tuning.
The project implements a method of learning. The input is properly formatted string.
The resulting information is aggregated and used in the future for proper indenting.

There are 2 types of training: minimum and maximum indents.

Training starts with the command `ruby learner_test.rb`.
It is not required by default.
The resulting information is stored in files `max_by_type.dat` and `min_by_type.dat`.

##Installation

First of all, make sure that your system has a ruby interpreter.
In Ubuntu you can use following command:
```
sudo apt-get install ruby
```

To install the plugin, clone it to your Siblime Text 2/3 Package directory with following command:

```
cd <path_to_package_dir>
git clone https://github.com/generall/aligner.git
```

Default hotkey for aligment is: `["ctrl+k","ctrl+a"]`.
