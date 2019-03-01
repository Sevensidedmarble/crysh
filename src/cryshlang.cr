require "readline"
require "./cryshlang/lexer"
require "./cryshlang/ast"
require "./cryshlang/scope"
require "./cryshlang/parser"
require "./cryshlang/exceptions"
require "../../src/cltk/macros"
require "../../src/cltk/parser/type"
require "../../src/cltk/parser/parser_concern"

lexer  = EXP_LANG::Lexer
parser = EXP_LANG::Parser
scope  = EXP_LANG::Scope(Expression).new

input = ""

puts "\n\n" +
     "  Welcome to the CryshLang REPL, exit with: 'exit'  \n" +
     "----------------------------------------------------\n\n"

while true
  begin

    # read input
    input = Readline.readline("»  ", true) || ""

    # exit on exit

    exit if input == "exit"

    # lex input
    tokens = lexer.lex(input)
    pp tokens

    # parse lexed tokens
    res = parser.parse(tokens, {accept: :first}).as(CLTK::ASTNode)
    pp res

    # evaluate the result with a given scope
    # (scope my be altered by the expression)
    evaluated = res.eval_scope(scope).to_s

    # output result of evaluation
    puts evaluated

  rescue e: CLTK::Lexer::Exceptions::LexingError
    show_lexing_error(e, input)
  rescue e: CLTK::NotInLanguage
    show_syntax_error(e,input)
  rescue e
    puts e
  end
end

def show_lexing_error(e, input)
  puts "Lexing error at:\n\n"
  puts "    " + input.split("\n")[e.line_number-1]
  puts "    " + e.line_offset.times().map { "-" }.join + "^"
  puts e
end

def show_syntax_error(e,input)
    pos = e.current.position
    if pos
      puts "Syntax error at:"
      puts "    " + input.split("\n")[pos.line_number-1]
      puts "    " + pos.line_offset.times().map { "-" }.join + "^"
    else
      puts "invalid input: #{input}"
    end
end
