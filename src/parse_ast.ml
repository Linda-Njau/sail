(* generated by Ott 0.22 from: l2_parse.ott *)


type text = string

type l =
  | Unknown
  | Trans of string * l option
  | Range of Lexing.position * Lexing.position

type 'a annot = l * 'a

exception Parse_error_locn of l * string


type x = text (* identifier *)
type ix = text (* infix identifier *)

type 
base_kind_aux =  (* base kind *)
   BK_type (* kind of types *)
 | BK_nat (* kind of natural number size expressions *)
 | BK_order (* kind of vector order specifications *)
 | BK_effects (* kind of effect sets *)


type 
efct_aux =  (* effect *)
   Effect_rreg (* read register *)
 | Effect_wreg (* write register *)
 | Effect_rmem (* read memory *)
 | Effect_wmem (* write memory *)
 | Effect_undef (* undefined-instruction exception *)
 | Effect_unspec (* unspecified values *)
 | Effect_nondet (* nondeterminism from intra-instruction parallelism *)


type 
id_aux =  (* Identifier *)
   Id of x
 | DeIid of x (* remove infix status *)


type 
base_kind = 
   BK_aux of base_kind_aux * l


type 
efct = 
   Effect_aux of efct_aux * l


type 
id = 
   Id_aux of id_aux * l


type 
kind_aux =  (* kinds *)
   K_kind of (base_kind) list


type 
atyp_aux =  (* expressions of all kinds, to be translated to types, nats, orders, and effects after parsing *)
   ATyp_id of id (* identifier *)
 | ATyp_constant of int (* constant *)
 | ATyp_times of atyp * atyp (* product *)
 | ATyp_sum of atyp * atyp (* sum *)
 | ATyp_exp of atyp (* exponential *)
 | ATyp_inc (* increasing (little-endian) *)
 | ATyp_dec (* decreasing (big-endian) *)
 | ATyp_efid of id
 | ATyp_set of (efct) list (* effect set *)
 | ATyp_wild (* Unspecified type *)
 | ATyp_fn of atyp * atyp * atyp (* Function type (first-order only in user code), last atyp is an effect *)
 | ATyp_tup of (atyp) list (* Tuple type *)
 | ATyp_app of id * (atyp) list (* type constructor application *)

and atyp = 
   ATyp_aux of atyp_aux * l


type 
kind = 
   K_aux of kind_aux * l


type 
nexp_constraint_aux =  (* constraint over kind $_$ *)
   NC_fixed of atyp * atyp
 | NC_bounded_ge of atyp * atyp
 | NC_bounded_le of atyp * atyp
 | NC_nat_set_bounded of id * (int) list


type 
kinded_id_aux =  (* optionally kind-annotated identifier *)
   KOpt_none of id (* identifier *)
 | KOpt_kind of kind * id (* kind-annotated variable *)


type 
nexp_constraint = 
   NC_aux of nexp_constraint_aux * l


type 
kinded_id = 
   KOpt_aux of kinded_id_aux * l


type 
quant_item_aux =  (* Either a kinded identifier or a nexp constraint for a typquant *)
   QI_id of kinded_id (* An optionally kinded identifier *)
 | QI_const of nexp_constraint (* A constraint for this type *)


type 
quant_item = 
   QI_aux of quant_item_aux * l


type 
typquant_aux =  (* type quantifiers and constraints *)
   TypQ_tq of (quant_item) list
 | TypQ_no_forall (* sugar, omitting quantifier and constraints *)


type 
lit_aux =  (* Literal constant *)
   L_unit (* $() : _$ *)
 | L_zero (* $_ : _$ *)
 | L_one (* $_ : _$ *)
 | L_true (* $_ : _$ *)
 | L_false (* $_ : _$ *)
 | L_num of int (* natural number constant *)
 | L_hex of string (* bit vector constant, C-style *)
 | L_bin of string (* bit vector constant, C-style *)
 | L_string of string (* string constant *)


type 
typquant = 
   TypQ_aux of typquant_aux * l


type 
lit = 
   L_aux of lit_aux * l


type 
typschm_aux =  (* type scheme *)
   TypSchm_ts of typquant * atyp


type 
pat_aux =  (* Pattern *)
   P_lit of lit (* literal constant pattern *)
 | P_wild (* wildcard *)
 | P_as of pat * id (* named pattern *)
 | P_typ of atyp * pat (* typed pattern *)
 | P_id of id (* identifier *)
 | P_app of id * (pat) list (* union constructor pattern *)
 | P_record of (fpat) list * bool (* struct pattern *)
 | P_vector of (pat) list (* vector pattern *)
 | P_vector_indexed of ((int * pat)) list (* vector pattern (with explicit indices) *)
 | P_vector_concat of (pat) list (* concatenated vector pattern *)
 | P_tup of (pat) list (* tuple pattern *)
 | P_list of (pat) list (* list pattern *)

and pat = 
   P_aux of pat_aux * l

and fpat_aux =  (* Field pattern *)
   FP_Fpat of id * pat

and fpat = 
   FP_aux of fpat_aux * l


type 
typschm = 
   TypSchm_aux of typschm_aux * l


type 
exp_aux =  (* Expression *)
   E_block of (exp) list (* block (parsing conflict with structs?) *)
 | E_id of id (* identifier *)
 | E_lit of lit (* literal constant *)
 | E_cast of atyp * exp (* cast *)
 | E_app of exp * (exp) list (* function application *)
 | E_app_infix of exp * id * exp (* infix function application *)
 | E_tuple of (exp) list (* tuple *)
 | E_if of exp * exp * exp (* conditional *)
 | E_for of id * exp * exp * exp * exp (* loop *)
 | E_vector of (exp) list (* vector (indexed from 0) *)
 | E_vector_indexed of ((int * exp)) list (* vector (indexed consecutively) *)
 | E_vector_access of exp * exp (* vector access *)
 | E_vector_subrange of exp * exp * exp (* subvector extraction *)
 | E_vector_update of exp * exp * exp (* vector functional update *)
 | E_vector_update_subrange of exp * exp * exp * exp (* vector subrange update (with vector) *)
 | E_list of (exp) list (* list *)
 | E_cons of exp * exp (* cons *)
 | E_record of fexps (* struct *)
 | E_record_update of exp * (exp) list (* functional update of struct *)
 | E_field of exp * id (* field projection from struct *)
 | E_case of exp * (pexp) list (* pattern matching *)
 | E_let of letbind * exp (* let expression *)
 | E_assign of exp * exp (* imperative assignment *)

and exp = 
   E_aux of exp_aux * l

and fexp_aux =  (* Field-expression *)
   FE_Fexp of id * exp

and fexp = 
   FE_aux of fexp_aux * l

and fexps_aux =  (* Field-expression list *)
   FES_Fexps of (fexp) list * bool

and fexps = 
   FES_aux of fexps_aux * l

and pexp_aux =  (* Pattern match *)
   Pat_exp of pat * exp

and pexp = 
   Pat_aux of pexp_aux * l

and letbind_aux =  (* Let binding *)
   LB_val_explicit of typschm * pat * exp (* value binding, explicit type (pat must be total) *)
 | LB_val_implicit of pat * exp (* value binding, implicit type (pat must be total) *)

and letbind = 
   LB_aux of letbind_aux * l


type 
naming_scheme_opt_aux =  (* Optional variable-naming-scheme specification for variables of defined type *)
   Name_sect_none
 | Name_sect_some of string


type 
tannot_opt_aux =  (* Optional type annotation for functions *)
   Typ_annot_opt_none
 | Typ_annot_opt_some of typquant * atyp


type 
effects_opt_aux =  (* Optional effect annotation for functions *)
   Effects_opt_pure (* sugar for empty effect set *)
 | Effects_opt_effects of atyp


type 
rec_opt_aux =  (* Optional recursive annotation for functions *)
   Rec_nonrec (* non-recursive *)
 | Rec_rec (* recursive *)


type 
funcl_aux =  (* Function clause *)
   FCL_Funcl of id * pat * exp


type 
index_range_aux =  (* index specification, for bitfields in register types *)
   BF_single of int (* single index *)
 | BF_range of int * int (* index range *)
 | BF_concat of index_range * index_range (* concatenation of index ranges *)

and index_range = 
   BF_aux of index_range_aux * l


type 
naming_scheme_opt = 
   Name_sect_aux of naming_scheme_opt_aux * l


type 
tannot_opt = 
   Typ_annot_opt_aux of tannot_opt_aux * l


type 
effects_opt = 
   Effects_opt_aux of effects_opt_aux * l


type 
rec_opt = 
   Rec_aux of rec_opt_aux * l


type 
funcl = 
   FCL_aux of funcl_aux * l


type 
val_spec_aux =  (* Value type specification *)
   VS_val_spec of typschm * id


type 
type_def_aux =  (* Type definition body *)
   TD_abbrev of id * naming_scheme_opt * typschm (* type abbreviation *)
 | TD_record of id * naming_scheme_opt * typquant * ((atyp * id)) list * bool (* struct type definition *)
 | TD_variant of id * naming_scheme_opt * typquant * ((atyp * id)) list * bool (* union type definition *)
 | TD_enum of id * naming_scheme_opt * (id) list * bool (* enumeration type definition *)
 | TD_register of id * atyp * atyp * ((index_range * id)) list (* register mutable bitfield type definition *)


type 
default_typing_spec_aux =  (* Default kinding or typing assumption *)
   DT_kind of base_kind * id
 | DT_typ of typschm * id


type 
fundef_aux =  (* Function definition *)
   FD_function of rec_opt * tannot_opt * effects_opt * (funcl) list


type 
val_spec = 
   VS_aux of val_spec_aux * l


type 
type_def = 
   TD_aux of type_def_aux * l


type 
default_typing_spec = 
   DT_aux of default_typing_spec_aux * l


type 
fundef = 
   FD_aux of fundef_aux * l


type 
def_aux =  (* Top-level definition *)
   DEF_type of type_def (* type definition *)
 | DEF_fundef of fundef (* function definition *)
 | DEF_val of letbind (* value definition *)
 | DEF_spec of val_spec (* top-level type constraint *)
 | DEF_default of default_typing_spec (* default kind and type assumptions *)
 | DEF_reg_dec of atyp * id (* register declaration *)
 | DEF_scattered_function of rec_opt * tannot_opt * effects_opt * id (* scattered function definition header *)
 | DEF_scattered_funcl of funcl (* scattered function definition clause *)
 | DEF_scattered_variant of id * naming_scheme_opt * typquant (* scattered union definition header *)
 | DEF_scattered_unioncl of id * atyp * id (* scattered union definition member *)
 | DEF_scattered_end of id (* scattered definition end *)


type 
def = 
   DEF_aux of def_aux * l


type 
ctor_def_aux =  (* Datatype constructor definition clause *)
   CT_ct of id * typschm


type 
typ_lib_aux =  (* library types and syntactic sugar for them *)
   Typ_lib_unit (* unit type with value $()$ *)
 | Typ_lib_bool (* booleans $_$ and $_$ *)
 | Typ_lib_bit (* pure bit values (not mutable bits) *)
 | Typ_lib_nat (* natural numbers 0,1,2,... *)
 | Typ_lib_string of string (* UTF8 strings *)
 | Typ_lib_enum (* natural numbers _ .. _+_-1, ordered by order *)
 | Typ_lib_enum1 (* sugar for \texttt{enum nexp 0 inc} *)
 | Typ_lib_enum2 (* sugar for \texttt{enum (nexp'-nexp+1) nexp inc} or \texttt{enum (nexp-nexp'+1) nexp' dec} *)
 | Typ_lib_vector of atyp (* vector of atyp, indexed by natural range *)
 | Typ_lib_vector2 of atyp (* sugar for vector indexed by [ atyp ] *)
 | Typ_lib_vector3 of atyp (* sugar for vector indexed by [ atyp.._ ] *)
 | Typ_lib_list of atyp (* list of atyp *)
 | Typ_lib_set of atyp (* finite set of atyp *)
 | Typ_lib_reg of atyp (* mutable register components holding atyp *)


type 
lexp_aux =  (* lvalue expression *)
   LEXP_id of id (* identifier *)
 | LEXP_vector of lexp * exp (* vector element *)
 | LEXP_vector_range of lexp * exp * exp (* subvector *)
 | LEXP_field of lexp * id (* struct field *)

and lexp = 
   LEXP_aux of lexp_aux * l


type 
defs =  (* Definition sequence *)
   Defs of (def) list


type 
ctor_def = 
   CT_aux of ctor_def_aux * l


type 
typ_lib = 
   Typ_lib_aux of typ_lib_aux * l



