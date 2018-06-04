import sys
import re

if len(sys.argv) != 6:
	# TODO: Build proper help message
	print "Invalid arguments!"
	sys.exit(1)

class Union:
	std_type  = ""
	specifier = ""
	type_name = ""

	def __init__(self, std_type, specifier, type_name):
		self.std_type  = std_type
		self.specifier = specifier
		self.type_name = type_name

	def str(self):
		return (self.std_type + " " if self.std_type else "") + \
			(self.specifier + " " if self.specifier else "") + \
			(self.type_name if self.type_name else "")

class TypeMap:
	type_name       = ""
	production_name = ""
	mapped          = False

	def __init__(self, type_name, production_name):
		self.type_name       = type_name
		self.production_name = production_name
		self.mapped          = False

	def str(self):
		return self.type_name + " -> " + self.production_name

class Rule:
	tokens = []

	def __init__(self, token_list):
		self.tokens = token_list

	def str(self):
		return ' '.join(self.tokens)

class Production:
	 name        = ""
	 name_prefix = ""
	 src_name    = ""
	 obj_name    = ""
	 prod_type   = TypeMap("<nil>", "<nil>")
	 rules       = []

	 def __init__(self, name):
	 	self.name  = name
	 	self.rules = []
	 	self.name_prefix = ParserGen.header_api_file[:ParserGen.header_api_file.rfind('.')] + "__" + self.name
	 	self.src_name = self.name_prefix + ".cpp"
	 	self.obj_name = self.name_prefix + ".o"

	 def add_rule(self, rule):
	 	self.rules.append(rule)

	 def str(self):
	 	ret = ">>>>>>>> Production: '" + self.name + "'\n"
	 	i = 1
	 	for rule in self.rules:
	 		ret += "> Rule " + str(i) + ": " + rule.str() + "\n"
	 		i += 1
	 	return ret

class ParserGen:
	# File names and directories of the source and target lexers/parsers (flex/lex + bison/yacc)	
	source_lexer_file    = ""
	source_parser_file   = ""
	target_lexer_file    = ""
	target_parser_file   = ""
	output_gen_dir       = "" # Directory where we'll output the parser backend files
	subdir_makefile_name = "subdir.mk"
	header_api_file      = "ast_node_gen.h"

	# Raw string from the lexers/parsers
	source_lexer  = ""
	source_parser = ""
	target_lexer  = ""
	target_parser = ""

	# Parsed union types (what node types may be allocated)
	union_types = []
	
	# List of type maps (from a type/class to a production)
	type_maps   = []

	# Output from the source parser (the final parsed productions)
	productions = []

	def __parse_union_types(self):
		# Compile the pattern that matches the declared union types
		pattern = re.compile(r"%union[^\w]*?{(.+?)}.*?;", re.MULTILINE | re.DOTALL)

		for (unions_decl) in re.findall(pattern, self.source_parser):
			# Remove multi-line and single line comments
			unions_decl = re.sub(r"(?:/\*(?:.|\n)+?\*/(?:.*?$)?|//.*)", "", unions_decl)

			# Carefully parse all of the specifiers of this union
			pattern = re.compile(r"(\w+(?:.|[^\*/]\n)+?);", re.MULTILINE | re.DOTALL)
			for(unions) in re.findall(pattern, unions_decl):
				union_fields    = unions.split()
				union_std_type  = ""
				union_specifier = ""

				for i in range(len(union_fields) - 1):
					if union_fields[i][0] != '*':
						union_std_type += (" " if i > 0 else "") +  union_fields[i]
					else:
						for j in range(i, len(union_fields) - 1):
							if union_fields[j][0] == '*':
								union_specifier += union_fields[j]
							else:
								break
						break

				self.union_types.append(Union(union_std_type, union_specifier, union_fields[len(union_fields)-1]))

	def __parse_type_map(self):
		# Compile the pattern that matches the declared production types
		pattern = re.compile(r"%type.*?<(\w+)>.+?(\w+)", re.MULTILINE | re.DOTALL)

		for (type_name, production_name) in re.findall(pattern, self.source_parser):
			self.type_maps.append(TypeMap(type_name, production_name))
			
	def parse_source(self):
		# Map all of the union types supported by each production
		self.__parse_union_types()

		# Map all of the declared union types that map into each respective production
		self.__parse_type_map()

		# Compile THE pattern that matches ALL productions
		pattern = re.compile(r"^(\w+)?:.+?((?:\w|'|{).+?^[ ]*?;)", re.MULTILINE | re.DOTALL)

		# For every matched production...
		for (production, rules) in re.findall(pattern, self.source_parser):
			skip_this_production = False

			# Check if we need to remap this production into another different node type
			for i in range(len(self.type_maps)):
				mapped_production = False

				if self.type_maps[i].production_name == production:
					# If not mapped yet, map it and all of the other bindings that have the same production target
					if self.type_maps[i].mapped == False:
						for union_type in self.union_types:
							if union_type.type_name == self.type_maps[i].type_name:
								production = union_type.std_type
								self.type_maps[i].mapped = True
								for j in range(len(self.type_maps)):
									if self.type_maps[j].type_name == self.type_maps[i].type_name:
										self.type_maps[j].mapped = True
								mapped_production = True
								break
					else: # Already generated this binded node type
						skip_this_production = True
						break

				if mapped_production == True:
					break

			# Don't create new productions in case this production in question is already mapped to a different one (many-to-one binding)
			if skip_this_production == True:
				continue

			# Create new production object
			production_obj = Production(production)

			# Split all rules by the | character
			rules_split = re.compile(r"[^']\|[^']").split(rules[:-1].strip())

			for j in range(len(rules_split)): # For each rule of this production...
				# Fetch only the grammar tokens
				idx = 0
				for k in range(len(rules_split[j])):
					if len(rules_split[j]) > k+1 and rules_split[j][k] == '{' and rules_split[j][k+1] != '\'':
						idx = k
						break

				tokens_only = rules_split[j][:idx].split()
				# Add this set of tokens into the production as a rule
				production_obj.add_rule(Rule(tokens_only))
			
			# Add newly built production into the output list
			self.productions.append(production_obj)

		# Done parsing

	def generate_output(self):
		# The contents of the makefile script will go here
		subdir_make_content = "GEN_OBJS += "

		# All header API content will go here
		header_api_content = """#ifndef _AST_NODE_GEN_H_\n#define _AST_NODE_GEN_H_\n
/****************************************************/
/* WARNING: DO NOT MODIFY. THIS IS A GENERATED FILE */
/****************************************************/\n
/* Forward declarations of all production nodes: */\n"""
		
		# Write forward declarations and target objects into the subdir makefile
		for production in self.productions:
			# Add this production node to the API as a forward declaration
			header_api_content += "class " + production.name + ";\n"
			# Add this production to the makefile as an object to be built by the rule 'make target'
			subdir_make_content += "$(OBJ)/" + production.obj_name + " \\\n\t"

		subdir_make_content += "\n"

		header_api_content += "\n#endif\n"
		
		for production in self.productions:
			# Add this production to the subdir makefile as a build target
			subdir_make_content += "\n$(OBJ)/" + production.obj_name + ": $(GEN_BACKEND)/" + production.src_name + "\n\t"
			subdir_make_content += "$(CXX) -o $@ -c $^ $(CPPFLAGS)\n"
			
			# Build source file string contents for this production
			production_source_gen = "#include <backend.h>\n#include <frontend.h>\n\n"
			production_source_gen += "class " + production.name + " {\npublic:\n\t"+production.name+"() {\n\n\t}\n};\n"

			# Create source file
			with open(self.output_gen_dir + "/" + production.src_name, "w") as production_src_file:
				production_src_file.write(production_source_gen)
	
		# Generate include header with all the nodes for the frontend
		with open(self.output_gen_dir + "/" + self.header_api_file, "w") as header_api_file_handle:
			header_api_file_handle.write(header_api_content)
	
		# Generate makefile for the backend
		with open(self.output_gen_dir + "/" + self.subdir_makefile_name, "w") as subdir_makefile:
			subdir_makefile.write(subdir_make_content)
	
	def __init__(self, source_lexer_file, source_parser_file, target_lexer_file, target_parser_file, output_gen_dir):
		self.output_gen_dir = output_gen_dir;

		# Get raw lexer text
		self.source_lexer_file = source_lexer_file
		with open(source_lexer_file) as file:
			self.source_lexer = file.read()

		# Get raw parser text
		self.source_parser_file = source_parser_file
		with open(source_parser_file) as file:
			self.source_parser = file.read()
		
		# Get raw TARGET lexer text
		self.target_lexer_file = target_lexer_file
		with open(target_lexer_file) as file:
			self.target_lexer = file.read()
		
		# Get raw TARGET parser text
		self.target_parser_file = target_parser_file
		with open(target_parser_file) as file:
			self.target_parser = file.read()

	def str(self):
		i = 1
		ret = ">>>> Total union types: " + str(len(self.union_types)) + "\n"
		for union_type in self.union_types:
			ret += "(" + str(i) + ") " + union_type.str() + "\n"
			i += 1

		i = 1
		ret += "\n>>>> Total production type bindings: " + str(len(self.type_maps)) + "\n"
		for type_map in self.type_maps:
			ret += "(" + str(i) + ") " + type_map.str() + "\n"
			i += 1

		i = 1
		ret += "\n>>>> Total productions: " + str(len(self.productions)) + "\n"
		for production in self.productions:
			ret += "(" + str(i) + ") " + production.str() + "\n"
			i += 1

		return ret[:-1]

# Create a new Parser Generator object
parserGen = ParserGen(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])

# Parse the source yacc/bison file
parserGen.parse_source()

# Generate parser backend code
parserGen.generate_output()

# Dump the results
print parserGen.str()
