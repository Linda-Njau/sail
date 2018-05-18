(*Generated by Lem from word.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_boolTheory lem_maybeTheory lem_numTheory lem_basic_classesTheory lem_listTheory wordsTheory wordsLib;

val _ = numLib.prefer_num();



val _ = new_theory "lem_word"



(*open import Bool Maybe Num Basic_classes List*)

(*open import {isabelle} `~~/src/HOL/Word/Word`*)
(*open import {hol} `wordsTheory` `wordsLib`*)


(* ========================================================================== *)
(* Define general purpose word, i.e. sequences of bits of arbitrary length    *)
(* ========================================================================== *)

val _ = Hol_datatype `
 bitSequence = BitSeq of 
    num option  => (* length of the sequence, Nothing means infinite length *)
   bool => bool       (* sign of the word, used to fill up after concrete value is exhausted *)
   list`;
    (* the initial part of the sequence, least significant bit first *)

(*val bitSeqEq : bitSequence -> bitSequence -> bool*)

(*val boolListFrombitSeq : nat -> bitSequence -> list bool*)

 val _ = Define `
 ((boolListFrombitSeqAux:num -> 'a -> 'a list -> 'a list) n s bl=
   (if n =( 0 : num) then [] else
  (case bl of
      []       => REPLICATE n s
    | b :: bl' => b :: (boolListFrombitSeqAux (n -( 1 : num)) s bl')
  )))`;


val _ = Define `
 ((boolListFrombitSeq:num -> bitSequence ->(bool)list) n (BitSeq _ s bl)=  (boolListFrombitSeqAux n s bl))`;



(*val bitSeqFromBoolList : list bool -> maybe bitSequence*)
val _ = Define `
 ((bitSeqFromBoolList:(bool)list ->(bitSequence)option) bl=
   ((case dest_init bl of
      NONE => NONE
    | SOME (bl', s) => SOME (BitSeq (SOME (LENGTH bl)) s bl')
  )))`;



(* cleans up the representation of a bitSequence without changing its semantics *)
(*val cleanBitSeq : bitSequence -> bitSequence*)
val _ = Define `
 ((cleanBitSeq:bitSequence -> bitSequence) (BitSeq len s bl)=  ((case len of
    NONE => (BitSeq len s (REVERSE (dropWhile ((<=>) s) (REVERSE bl))))
  | SOME n  => (BitSeq len s (REVERSE (dropWhile ((<=>) s) (REVERSE (TAKE (n -( 1 : num)) bl)))))
)))`;



(*val bitSeqTestBit : bitSequence -> nat -> maybe bool*)
val _ = Define `
 ((bitSeqTestBit:bitSequence -> num ->(bool)option) (BitSeq NONE s bl) pos=  (if pos < LENGTH bl then list_index bl pos else SOME s))
/\ ((bitSeqTestBit:bitSequence -> num ->(bool)option) (BitSeq(SOME l) s bl) pos=  (if (pos >= l) then NONE else
                if ((pos = (l -( 1 : num))) \/ (pos >= LENGTH bl)) then SOME s else
                list_index bl pos))`;


(*val bitSeqSetBit : bitSequence -> nat -> bool -> bitSequence*)
val _ = Define `
 ((bitSeqSetBit:bitSequence -> num -> bool -> bitSequence) (BitSeq len s bl) pos v=
   (let bl' = (if (pos < LENGTH bl) then bl else bl ++ REPLICATE pos s) in
  let bl'' = (LUPDATE v pos bl') in
  let bs' = (BitSeq len s bl'') in
  cleanBitSeq bs'))`;



(*val resizeBitSeq : maybe nat -> bitSequence -> bitSequence*)
val _ = Define `
 ((resizeBitSeq:(num)option -> bitSequence -> bitSequence) new_len bs= 
  ((case cleanBitSeq bs of
       (BitSeq len s bl) =>
   let shorten_opt = ((case (new_len, len) of
                            (NONE, _) => NONE
                        | (SOME l1, NONE) => SOME l1
                        | (SOME l1, SOME l2) =>
                      if (l1 < l2) then SOME l1 else NONE
                      )) in
   (case shorten_opt of
         NONE => BitSeq new_len s bl
     | SOME l1 => (
                  let bl' = (TAKE l1 (bl ++ [s])) in
                  (case dest_init bl' of
                        NONE => (BitSeq len s bl) (* do nothing if size 0 is requested *)
                    | SOME (bl'', s') => cleanBitSeq (BitSeq new_len s' bl'')
                  ))
   )
   )))`;
 

(*val bitSeqNot : bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqNot:bitSequence -> bitSequence) (BitSeq len s bl)=  (BitSeq len (~ s) (MAP (\ x. ~ x) bl)))`;


(*val bitSeqBinop : (bool -> bool -> bool) -> bitSequence -> bitSequence -> bitSequence*)

(*val bitSeqBinopAux : (bool -> bool -> bool) -> bool -> list bool -> bool -> list bool -> list bool*)
 val _ = Define `
 ((bitSeqBinopAux:(bool -> bool -> bool) -> bool ->(bool)list -> bool ->(bool)list ->(bool)list) binop s1 ([]) s2 ([])=  ([]))
/\ ((bitSeqBinopAux:(bool -> bool -> bool) -> bool ->(bool)list -> bool ->(bool)list ->(bool)list) binop s1 (b1 :: bl1') s2 ([])=  ((binop b1 s2) :: bitSeqBinopAux binop s1 bl1' s2 []))
/\ ((bitSeqBinopAux:(bool -> bool -> bool) -> bool ->(bool)list -> bool ->(bool)list ->(bool)list) binop s1 ([]) s2 (b2 :: bl2')=  ((binop s1 b2) :: bitSeqBinopAux binop s1 []   s2 bl2'))
/\ ((bitSeqBinopAux:(bool -> bool -> bool) -> bool ->(bool)list -> bool ->(bool)list ->(bool)list) binop s1 (b1 :: bl1') s2 (b2 :: bl2')=  ((binop b1 b2) :: bitSeqBinopAux binop s1 bl1' s2 bl2'))`;


val _ = Define `
 ((bitSeqBinop:(bool -> bool -> bool) -> bitSequence -> bitSequence -> bitSequence) binop bs1 bs2=  ( 
  (case cleanBitSeq bs1 of
      (BitSeq len1 s1 bl1) =>
  (case cleanBitSeq bs2 of
      (BitSeq len2 s2 bl2) =>
  let len = ((case (len1, len2) of
                   (SOME l1, SOME l2) => SOME (MAX l1 l2)
               | _ => NONE
             )) in
  let s = (binop s1 s2) in
  let bl = (bitSeqBinopAux binop s1 bl1 s2 bl2) in
  cleanBitSeq (BitSeq len s bl)
  )
  )
))`;


val _ = Define `
 ((bitSeqAnd:bitSequence -> bitSequence -> bitSequence)=  (bitSeqBinop (/\)))`;

val _ = Define `
 ((bitSeqOr:bitSequence -> bitSequence -> bitSequence)=  (bitSeqBinop (\/)))`;

val _ = Define `
 ((bitSeqXor:bitSequence -> bitSequence -> bitSequence)=  (bitSeqBinop (\ b1 b2. ~ (b1 <=> b2))))`;


(*val bitSeqShiftLeft : bitSequence -> nat -> bitSequence*)
val _ = Define `
 ((bitSeqShiftLeft:bitSequence -> num -> bitSequence) (BitSeq len s bl) n=  (cleanBitSeq (BitSeq len s (REPLICATE n F ++ bl))))`;


(*val bitSeqArithmeticShiftRight : bitSequence -> nat -> bitSequence*)
val _ = Define `
 ((bitSeqArithmeticShiftRight:bitSequence -> num -> bitSequence) bs n= 
  ((case cleanBitSeq bs of
       (BitSeq len s bl) =>
   cleanBitSeq (BitSeq len s (DROP n bl))
   )))`;


(*val bitSeqLogicalShiftRight : bitSequence -> nat -> bitSequence*)
val _ = Define `
 ((bitSeqLogicalShiftRight:bitSequence -> num -> bitSequence) bs n= 
   (if (n =( 0 : num)) then cleanBitSeq bs else  
  (case cleanBitSeq bs of
      (BitSeq len s bl) =>
  (case len of
        NONE => cleanBitSeq (BitSeq len s (DROP n bl))
    | SOME l => cleanBitSeq (BitSeq len F ((DROP n bl) ++ REPLICATE l s))
  )
  )))`;



(* integerFromBoolList sign bl creates an integer from a list of bits
   (least significant bit first) and an explicitly given sign bit.
   It uses two's complement encoding. *)
(*val integerFromBoolList : (bool * list bool) -> integer*)

 val _ = Define `
 ((integerFromBoolListAux:int ->(bool)list -> int) (acc : int) (([]) : bool list)=  acc)
/\ ((integerFromBoolListAux:int ->(bool)list -> int) (acc : int) ((T :: bl') : bool list)=  (integerFromBoolListAux ((acc *( 2 : int)) +( 1 : int)) bl'))
/\ ((integerFromBoolListAux:int ->(bool)list -> int) (acc : int) ((F :: bl') : bool list)=  (integerFromBoolListAux (acc *( 2 : int)) bl'))`;


val _ = Define `
 ((integerFromBoolList:bool#(bool)list -> int) (sign, bl)= 
    (if sign then 
     ~ (integerFromBoolListAux(( 0 : int)) (REVERSE (MAP (\ x. ~ x) bl)) +( 1 : int))
   else integerFromBoolListAux(( 0 : int)) (REVERSE bl)))`;


(* [boolListFromInteger i] creates a sign bit and a list of booleans from an integer. The len_opt tells it when to stop.*)
(*val boolListFromInteger :    integer -> bool * list bool*)

 val _ = Define `
 ((boolListFromNatural:(bool)list -> num ->(bool)list) acc (remainder : num)=
  (if (remainder >( 0:num)) then 
   (boolListFromNatural (((remainder MOD( 2:num)) =( 1:num)) :: acc) 
      (remainder DIV( 2:num)))
 else
   REVERSE acc))`;


val _ = Define `
 ((boolListFromInteger:int -> bool#(bool)list) (i : int)= 
   (if (i <( 0 : int)) then
    (T, MAP (\ x. ~ x) (boolListFromNatural [] (Num (ABS (~ (i +( 1 : int)))))))
  else
    (F, boolListFromNatural [] (Num (ABS i)))))`;



(* [bitSeqFromInteger len_opt i] encodes [i] as a bitsequence with [len_opt] bits. If there are not enough
   bits, truncation happens *)
(*val bitSeqFromInteger : maybe nat -> integer -> bitSequence*)
val _ = Define `
 ((bitSeqFromInteger:(num)option -> int -> bitSequence) len_opt i=
   (let (s, bl) = (boolListFromInteger i) in
  resizeBitSeq len_opt (BitSeq NONE s bl)))`;



(*val integerFromBitSeq : bitSequence -> integer*)
val _ = Define `
 ((integerFromBitSeq:bitSequence -> int) bs= 
  ((case cleanBitSeq bs of (BitSeq len s bl) => integerFromBoolList (s, bl) )))`;



(* Now we can via translation to integers map arithmetic operations to bitSequences *)

(*val bitSeqArithUnaryOp : (integer -> integer) -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqArithUnaryOp:(int -> int) -> bitSequence -> bitSequence) uop bs= 
  ((case bs of
       (BitSeq len _ _) =>
   bitSeqFromInteger len (uop (integerFromBitSeq bs))
   )))`;


(*val bitSeqArithBinOp : (integer -> integer -> integer) -> bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqArithBinOp:(int -> int -> int) -> bitSequence -> bitSequence -> bitSequence) binop bs1 bs2= 
  ((case bs1 of
       (BitSeq len1 _ _) =>
   (case bs2 of
       (BitSeq len2 _ _) =>
   let len = ((case (len1, len2) of
                    (SOME l1, SOME l2) => SOME (MAX l1 l2)
                | _ => NONE
              )) in
   bitSeqFromInteger len
     (binop (integerFromBitSeq bs1) (integerFromBitSeq bs2))
   )
   )))`;


(*val bitSeqArithBinTest : forall 'a. (integer -> integer -> 'a) -> bitSequence -> bitSequence -> 'a*)
val _ = Define `
 ((bitSeqArithBinTest:(int -> int -> 'a) -> bitSequence -> bitSequence -> 'a) binop bs1 bs2=  (binop (integerFromBitSeq bs1) (integerFromBitSeq bs2)))`;



(* now instantiate the number interface for bit-sequences *)

(*val bitSeqFromNumeral : numeral -> bitSequence*)

(*val bitSeqLess : bitSequence -> bitSequence -> bool*)
val _ = Define `
 ((bitSeqLess:bitSequence -> bitSequence -> bool) bs1 bs2=  (bitSeqArithBinTest (<) bs1 bs2))`;


(*val bitSeqLessEqual : bitSequence -> bitSequence -> bool*)
val _ = Define `
 ((bitSeqLessEqual:bitSequence -> bitSequence -> bool) bs1 bs2=  (bitSeqArithBinTest (<=) bs1 bs2))`;


(*val bitSeqGreater : bitSequence -> bitSequence -> bool*)
val _ = Define `
 ((bitSeqGreater:bitSequence -> bitSequence -> bool) bs1 bs2=  (bitSeqArithBinTest (>) bs1 bs2))`;


(*val bitSeqGreaterEqual : bitSequence -> bitSequence -> bool*)
val _ = Define `
 ((bitSeqGreaterEqual:bitSequence -> bitSequence -> bool) bs1 bs2=  (bitSeqArithBinTest (>=) bs1 bs2))`;


(*val bitSeqCompare : bitSequence -> bitSequence -> ordering*)
val _ = Define `
 ((bitSeqCompare:bitSequence -> bitSequence -> ordering) bs1 bs2=  (bitSeqArithBinTest (genericCompare (<) (=)) bs1 bs2))`;


val _ = Define `
((instance_Basic_classes_Ord_Word_bitSequence_dict:(bitSequence)Ord_class)= (<|

  compare_method := bitSeqCompare;

  isLess_method := bitSeqLess;

  isLessEqual_method := bitSeqLessEqual;

  isGreater_method := bitSeqGreater;

  isGreaterEqual_method := bitSeqGreaterEqual|>))`;


(* arithmetic negation, don't mix up with bitwise negation *)
(*val bitSeqNegate : bitSequence -> bitSequence*) 
val _ = Define `
 ((bitSeqNegate:bitSequence -> bitSequence) bs=  (bitSeqArithUnaryOp (\ i. ~ i) bs))`;


val _ = Define `
((instance_Num_NumNegate_Word_bitSequence_dict:(bitSequence)NumNegate_class)= (<|

  numNegate_method := bitSeqNegate|>))`;



(*val bitSeqAdd : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqAdd:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp (+) bs1 bs2))`;


val _ = Define `
((instance_Num_NumAdd_Word_bitSequence_dict:(bitSequence)NumAdd_class)= (<|

  numAdd_method := bitSeqAdd|>))`;


(*val bitSeqMinus : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqMinus:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp (-) bs1 bs2))`;


val _ = Define `
((instance_Num_NumMinus_Word_bitSequence_dict:(bitSequence)NumMinus_class)= (<|

  numMinus_method := bitSeqMinus|>))`;


(*val bitSeqSucc : bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqSucc:bitSequence -> bitSequence) bs=  (bitSeqArithUnaryOp (\ n. n +( 1 : int)) bs))`;


val _ = Define `
((instance_Num_NumSucc_Word_bitSequence_dict:(bitSequence)NumSucc_class)= (<|

  succ_method := bitSeqSucc|>))`;


(*val bitSeqPred : bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqPred:bitSequence -> bitSequence) bs=  (bitSeqArithUnaryOp (\ n. n -( 1 : int)) bs))`;


val _ = Define `
((instance_Num_NumPred_Word_bitSequence_dict:(bitSequence)NumPred_class)= (<|

  pred_method := bitSeqPred|>))`;


(*val bitSeqMult : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqMult:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp ( * ) bs1 bs2))`;


val _ = Define `
((instance_Num_NumMult_Word_bitSequence_dict:(bitSequence)NumMult_class)= (<|

  numMult_method := bitSeqMult|>))`;



(*val bitSeqPow : bitSequence -> nat -> bitSequence*)
val _ = Define `
 ((bitSeqPow:bitSequence -> num -> bitSequence) bs n=  (bitSeqArithUnaryOp (\ i .  i ** n) bs))`;


val _ = Define `
((instance_Num_NumPow_Word_bitSequence_dict:(bitSequence)NumPow_class)= (<|

  numPow_method := bitSeqPow|>))`;


(*val bitSeqDiv : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqDiv:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp (/) bs1 bs2))`;


val _ = Define `
((instance_Num_NumIntegerDivision_Word_bitSequence_dict:(bitSequence)NumIntegerDivision_class)= (<|

  div_method := bitSeqDiv|>))`;


val _ = Define `
((instance_Num_NumDivision_Word_bitSequence_dict:(bitSequence)NumDivision_class)= (<|

  numDivision_method := bitSeqDiv|>))`;


(*val bitSeqMod : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqMod:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp (%) bs1 bs2))`;


val _ = Define `
((instance_Num_NumRemainder_Word_bitSequence_dict:(bitSequence)NumRemainder_class)= (<|

  mod_method := bitSeqMod|>))`;


(*val bitSeqMin : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqMin:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp int_min bs1 bs2))`;


(*val bitSeqMax : bitSequence -> bitSequence -> bitSequence*)
val _ = Define `
 ((bitSeqMax:bitSequence -> bitSequence -> bitSequence) bs1 bs2=  (bitSeqArithBinOp int_max bs1 bs2))`;


val _ = Define `
((instance_Basic_classes_OrdMaxMin_Word_bitSequence_dict:(bitSequence)OrdMaxMin_class)= (<|

  max_method := bitSeqMax;

  min_method := bitSeqMin|>))`;





(* ========================================================================== *)
(* Interface for bitoperations                                                *)
(* ========================================================================== *)

val _ = Hol_datatype `
(*  'a *) WordNot_class= <|
  lnot_method : 'a -> 'a
|>`;


val _ = Hol_datatype `
(*  'a *) WordAnd_class= <|
  land_method  : 'a -> 'a -> 'a
|>`;


val _ = Hol_datatype `
(*  'a *) WordOr_class= <|
  lor_method : 'a -> 'a -> 'a
|>`;



val _ = Hol_datatype `
(*  'a *) WordXor_class= <|
  lxor_method : 'a -> 'a -> 'a
|>`;


val _ = Hol_datatype `
(*  'a *) WordLsl_class= <|
  lsl_method : 'a -> num -> 'a
|>`;


val _ = Hol_datatype `
(*  'a *) WordLsr_class= <|
  lsr_method : 'a -> num -> 'a
|>`;


val _ = Hol_datatype `
(*  'a *) WordAsr_class= <|
  asr_method : 'a -> num -> 'a
|>`;


(* ----------------------- *)
(* bitSequence             *)
(* ----------------------- *)

val _ = Define `
((instance_Word_WordNot_Word_bitSequence_dict:(bitSequence)WordNot_class)= (<|

  lnot_method := bitSeqNot|>))`;


val _ = Define `
((instance_Word_WordAnd_Word_bitSequence_dict:(bitSequence)WordAnd_class)= (<|

  land_method := bitSeqAnd|>))`;


val _ = Define `
((instance_Word_WordOr_Word_bitSequence_dict:(bitSequence)WordOr_class)= (<|

  lor_method := bitSeqOr|>))`;


val _ = Define `
((instance_Word_WordXor_Word_bitSequence_dict:(bitSequence)WordXor_class)= (<|

  lxor_method := bitSeqXor|>))`;


val _ = Define `
((instance_Word_WordLsl_Word_bitSequence_dict:(bitSequence)WordLsl_class)= (<|

  lsl_method := bitSeqShiftLeft|>))`;


val _ = Define `
((instance_Word_WordLsr_Word_bitSequence_dict:(bitSequence)WordLsr_class)= (<|

  lsr_method := bitSeqLogicalShiftRight|>))`;


val _ = Define `
((instance_Word_WordAsr_Word_bitSequence_dict:(bitSequence)WordAsr_class)= (<|

  asr_method := bitSeqArithmeticShiftRight|>))`;



(* ----------------------- *)
(* int32                   *)
(* ----------------------- *)

(*val int32Lnot : int32 -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordNot_Num_int32_dict:(word32)WordNot_class)= (<|

  lnot_method := (\ w. (~ w))|>))`;



(*val int32Lor  : int32 -> int32 -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordOr_Num_int32_dict:(word32)WordOr_class)= (<|

  lor_method := word_or|>))`;


(*val int32Lxor : int32 -> int32 -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordXor_Num_int32_dict:(word32)WordXor_class)= (<|

  lxor_method := word_xor|>))`;


(*val int32Land : int32 -> int32 -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordAnd_Num_int32_dict:(word32)WordAnd_class)= (<|

  land_method := word_and|>))`;


(*val int32Lsl  : int32 -> nat -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordLsl_Num_int32_dict:(word32)WordLsl_class)= (<|

  lsl_method := word_lsl|>))`;


(*val int32Lsr  : int32 -> nat -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordLsr_Num_int32_dict:(word32)WordLsr_class)= (<|

  lsr_method := word_lsr|>))`;



(*val int32Asr  : int32 -> nat -> int32*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordAsr_Num_int32_dict:(word32)WordAsr_class)= (<|

  asr_method := word_asr|>))`;



(* ----------------------- *)
(* int64                   *)
(* ----------------------- *)

(*val int64Lnot : int64 -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordNot_Num_int64_dict:(word64)WordNot_class)= (<|

  lnot_method := (\ w. (~ w))|>))`;


(*val int64Lor  : int64 -> int64 -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordOr_Num_int64_dict:(word64)WordOr_class)= (<|

  lor_method := word_or|>))`;


(*val int64Lxor : int64 -> int64 -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordXor_Num_int64_dict:(word64)WordXor_class)= (<|

  lxor_method := word_xor|>))`;


(*val int64Land : int64 -> int64 -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordAnd_Num_int64_dict:(word64)WordAnd_class)= (<|

  land_method := word_and|>))`;


(*val int64Lsl  : int64 -> nat -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordLsl_Num_int64_dict:(word64)WordLsl_class)= (<|

  lsl_method := word_lsl|>))`;


(*val int64Lsr  : int64 -> nat -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordLsr_Num_int64_dict:(word64)WordLsr_class)= (<|

  lsr_method := word_lsr|>))`;


(*val int64Asr  : int64 -> nat -> int64*) (* XXX: fix *)

val _ = Define `
((instance_Word_WordAsr_Num_int64_dict:(word64)WordAsr_class)= (<|

  asr_method := word_asr|>))`;



(* ----------------------- *)
(* Words via bit sequences *)
(* ----------------------- *)

(*val defaultLnot : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> 'a*) 
val _ = Define `
 ((defaultLnot:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> 'a) fromBitSeq toBitSeq x=  (fromBitSeq (bitSeqNegate (toBitSeq x))))`;


(*val defaultLand : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> 'a -> 'a*)
val _ = Define `
 ((defaultLand:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> 'a -> 'a) fromBitSeq toBitSeq x1 x2=  (fromBitSeq (bitSeqAnd (toBitSeq x1) (toBitSeq x2))))`;


(*val defaultLor : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> 'a -> 'a*)
val _ = Define `
 ((defaultLor:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> 'a -> 'a) fromBitSeq toBitSeq x1 x2=  (fromBitSeq (bitSeqOr (toBitSeq x1) (toBitSeq x2))))`;


(*val defaultLxor : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> 'a -> 'a*)
val _ = Define `
 ((defaultLxor:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> 'a -> 'a) fromBitSeq toBitSeq x1 x2=  (fromBitSeq (bitSeqXor (toBitSeq x1) (toBitSeq x2))))`;


(*val defaultLsl : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> nat -> 'a*)
val _ = Define `
 ((defaultLsl:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> num -> 'a) fromBitSeq toBitSeq x n=  (fromBitSeq (bitSeqShiftLeft (toBitSeq x) n)))`;


(*val defaultLsr : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> nat -> 'a*)
val _ = Define `
 ((defaultLsr:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> num -> 'a) fromBitSeq toBitSeq x n=  (fromBitSeq (bitSeqLogicalShiftRight (toBitSeq x) n)))`;


(*val defaultAsr : forall 'a. (bitSequence -> 'a) -> ('a -> bitSequence) -> 'a -> nat -> 'a*)
val _ = Define `
 ((defaultAsr:(bitSequence -> 'a) ->('a -> bitSequence) -> 'a -> num -> 'a) fromBitSeq toBitSeq x n=  (fromBitSeq (bitSeqArithmeticShiftRight (toBitSeq x) n)))`;


(* ----------------------- *)
(* integer                 *)
(* ----------------------- *)

(*val integerLnot : integer -> integer*)
val _ = Define `
 ((integerLnot:int -> int) i=  (~ (i +( 1 : int))))`;


val _ = Define `
((instance_Word_WordNot_Num_integer_dict:(int)WordNot_class)= (<|

  lnot_method := integerLnot|>))`;



(*val integerLor  : integer -> integer -> integer*)
val _ = Define `
 ((integerLor:int -> int -> int) i1 i2=  (defaultLor integerFromBitSeq (bitSeqFromInteger NONE) i1 i2))`;


val _ = Define `
((instance_Word_WordOr_Num_integer_dict:(int)WordOr_class)= (<|

  lor_method := integerLor|>))`;


(*val integerLxor : integer -> integer -> integer*)
val _ = Define `
 ((integerLxor:int -> int -> int) i1 i2=  (defaultLxor integerFromBitSeq (bitSeqFromInteger NONE) i1 i2))`;


val _ = Define `
((instance_Word_WordXor_Num_integer_dict:(int)WordXor_class)= (<|

  lxor_method := integerLxor|>))`;


(*val integerLand : integer -> integer -> integer*)
val _ = Define `
 ((integerLand:int -> int -> int) i1 i2=  (defaultLand integerFromBitSeq (bitSeqFromInteger NONE) i1 i2))`;


val _ = Define `
((instance_Word_WordAnd_Num_integer_dict:(int)WordAnd_class)= (<|

  land_method := integerLand|>))`;


(*val integerLsl  : integer -> nat -> integer*)
val _ = Define `
 ((integerLsl:int -> num -> int) i n=  (defaultLsl integerFromBitSeq (bitSeqFromInteger NONE) i n))`;


val _ = Define `
((instance_Word_WordLsl_Num_integer_dict:(int)WordLsl_class)= (<|

  lsl_method := integerLsl|>))`;


(*val integerAsr  : integer -> nat -> integer*)
val _ = Define `
 ((integerAsr:int -> num -> int) i n=  (defaultAsr integerFromBitSeq (bitSeqFromInteger NONE) i n))`;


val _ = Define `
((instance_Word_WordLsr_Num_integer_dict:(int)WordLsr_class)= (<|

  lsr_method := integerAsr|>))`;


val _ = Define `
((instance_Word_WordAsr_Num_integer_dict:(int)WordAsr_class)= (<|

  asr_method := integerAsr|>))`;



(* ----------------------- *)
(* int                     *)
(* ----------------------- *)

(* sometimes it is convenient to be able to perform bit-operations on ints.
   However, since int is not well-defined (it has different size on different systems),
   it should be used very carefully and only for operations that don't depend on the
   bitwidth of int *)

(*val intFromBitSeq : bitSequence -> int*)
val _ = Define `
 ((intFromBitSeq:bitSequence -> int) bs=  (I (integerFromBitSeq (resizeBitSeq (SOME(( 31 : num))) bs))))`;



(*val bitSeqFromInt : int -> bitSequence*) 
val _ = Define `
 ((bitSeqFromInt:int -> bitSequence) i=  (bitSeqFromInteger (SOME(( 31 : num))) ( i)))`;



(*val intLnot : int -> int*)
val _ = Define `
 ((intLnot:int -> int) i=  (~ (i +( 1 : int))))`;


val _ = Define `
((instance_Word_WordNot_Num_int_dict:(int)WordNot_class)= (<|

  lnot_method := intLnot|>))`;


(*val intLor  : int -> int -> int*)
val _ = Define `
 ((intLor:int -> int -> int) i1 i2=  (defaultLor intFromBitSeq bitSeqFromInt i1 i2))`;


val _ = Define `
((instance_Word_WordOr_Num_int_dict:(int)WordOr_class)= (<|

  lor_method := intLor|>))`;


(*val intLxor : int -> int -> int*)
val _ = Define `
 ((intLxor:int -> int -> int) i1 i2=  (defaultLxor intFromBitSeq bitSeqFromInt i1 i2))`;


val _ = Define `
((instance_Word_WordXor_Num_int_dict:(int)WordXor_class)= (<|

  lxor_method := intLxor|>))`;


(*val intLand : int -> int -> int*)
val _ = Define `
 ((intLand:int -> int -> int) i1 i2=  (defaultLand intFromBitSeq bitSeqFromInt i1 i2))`;


val _ = Define `
((instance_Word_WordAnd_Num_int_dict:(int)WordAnd_class)= (<|

  land_method := intLand|>))`;


(*val intLsl  : int -> nat -> int*)
val _ = Define `
 ((intLsl:int -> num -> int) i n=  (defaultLsl intFromBitSeq bitSeqFromInt i n))`;


val _ = Define `
((instance_Word_WordLsl_Num_int_dict:(int)WordLsl_class)= (<|

  lsl_method := intLsl|>))`;


(*val intAsr  : int -> nat -> int*)
val _ = Define `
 ((intAsr:int -> num -> int) i n=  (defaultAsr intFromBitSeq bitSeqFromInt i n))`;


val _ = Define `
((instance_Word_WordAsr_Num_int_dict:(int)WordAsr_class)= (<|

  asr_method := intAsr|>))`;




(* ----------------------- *)
(* natural                 *)
(* ----------------------- *)

(* some operations work also on positive numbers *)

(*val naturalFromBitSeq : bitSequence -> natural*)
val _ = Define `
 ((naturalFromBitSeq:bitSequence -> num) bs=  (Num (ABS (integerFromBitSeq bs))))`;


(*val bitSeqFromNatural : maybe nat -> natural -> bitSequence*)
val _ = Define `
 ((bitSeqFromNatural:(num)option -> num -> bitSequence) len n=  (bitSeqFromInteger len (int_of_num n)))`;


(*val naturalLor  : natural -> natural -> natural*)
val _ = Define `
 ((naturalLor:num -> num -> num) i1 i2=  (defaultLor naturalFromBitSeq (bitSeqFromNatural NONE) i1 i2))`;


val _ = Define `
((instance_Word_WordOr_Num_natural_dict:(num)WordOr_class)= (<|

  lor_method := naturalLor|>))`;


(*val naturalLxor : natural -> natural -> natural*)
val _ = Define `
 ((naturalLxor:num -> num -> num) i1 i2=  (defaultLxor naturalFromBitSeq (bitSeqFromNatural NONE) i1 i2))`;


val _ = Define `
((instance_Word_WordXor_Num_natural_dict:(num)WordXor_class)= (<|

  lxor_method := naturalLxor|>))`;


(*val naturalLand : natural -> natural -> natural*)
val _ = Define `
 ((naturalLand:num -> num -> num) i1 i2=  (defaultLand naturalFromBitSeq (bitSeqFromNatural NONE) i1 i2))`;


val _ = Define `
((instance_Word_WordAnd_Num_natural_dict:(num)WordAnd_class)= (<|

  land_method := naturalLand|>))`;


(*val naturalLsl  : natural -> nat -> natural*)
val _ = Define `
 ((naturalLsl:num -> num -> num) i n=  (defaultLsl naturalFromBitSeq (bitSeqFromNatural NONE) i n))`;


val _ = Define `
((instance_Word_WordLsl_Num_natural_dict:(num)WordLsl_class)= (<|

  lsl_method := naturalLsl|>))`;


(*val naturalAsr  : natural -> nat -> natural*)
val _ = Define `
 ((naturalAsr:num -> num -> num) i n=  (defaultAsr naturalFromBitSeq (bitSeqFromNatural NONE) i n))`;


val _ = Define `
((instance_Word_WordLsr_Num_natural_dict:(num)WordLsr_class)= (<|

  lsr_method := naturalAsr|>))`;


val _ = Define `
((instance_Word_WordAsr_Num_natural_dict:(num)WordAsr_class)= (<|

  asr_method := naturalAsr|>))`;



(* ----------------------- *)
(* nat                     *)
(* ----------------------- *)

(* sometimes it is convenient to be able to perform bit-operations on nats.
   However, since nat is not well-defined (it has different size on different systems),
   it should be used very carefully and only for operations that don't depend on the
   bitwidth of nat *)

(*val natFromBitSeq : bitSequence -> nat*)
val _ = Define `
 ((natFromBitSeq:bitSequence -> num) bs=  (((naturalFromBitSeq (resizeBitSeq (SOME(( 31 : num))) bs)):num)))`;



(*val bitSeqFromNat : nat -> bitSequence*) 
val _ = Define `
 ((bitSeqFromNat:num -> bitSequence) i=  (bitSeqFromNatural (SOME(( 31 : num))) (( i:num))))`;



(*val natLor  : nat -> nat -> nat*)
val _ = Define `
 ((natLor:num -> num -> num) i1 i2=  (defaultLor natFromBitSeq bitSeqFromNat i1 i2))`;


val _ = Define `
((instance_Word_WordOr_nat_dict:(num)WordOr_class)= (<|

  lor_method := natLor|>))`;


(*val natLxor : nat -> nat -> nat*)
val _ = Define `
 ((natLxor:num -> num -> num) i1 i2=  (defaultLxor natFromBitSeq bitSeqFromNat i1 i2))`;


val _ = Define `
((instance_Word_WordXor_nat_dict:(num)WordXor_class)= (<|

  lxor_method := natLxor|>))`;


(*val natLand : nat -> nat -> nat*)
val _ = Define `
 ((natLand:num -> num -> num) i1 i2=  (defaultLand natFromBitSeq bitSeqFromNat i1 i2))`;


val _ = Define `
((instance_Word_WordAnd_nat_dict:(num)WordAnd_class)= (<|

  land_method := natLand|>))`;


(*val natLsl  : nat -> nat -> nat*)
val _ = Define `
 ((natLsl:num -> num -> num) i n=  (defaultLsl natFromBitSeq bitSeqFromNat i n))`;


val _ = Define `
((instance_Word_WordLsl_nat_dict:(num)WordLsl_class)= (<|

  lsl_method := natLsl|>))`;


(*val natAsr  : nat -> nat -> nat*)
val _ = Define `
 ((natAsr:num -> num -> num) i n=  (defaultAsr natFromBitSeq bitSeqFromNat i n))`;


val _ = Define `
((instance_Word_WordAsr_nat_dict:(num)WordAsr_class)= (<|

  asr_method := natAsr|>))`;


val _ = export_theory()

