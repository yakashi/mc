.//============================================================================
.// $RCSfile: t.smt_sr.chainto1.c,v $
.//
.// Notice:
.// (C) Copyright 1998-2012 Mentor Graphics Corporation
.//     All rights reserved.
.//
.// This document contains confidential and proprietary information and
.// property of Mentor Graphics Corp.  No part of this document may be
.// reproduced without the express written permission of Mentor Graphics Corp.
.//============================================================================
.assign b = b + "${ws}${te_lnk.te_classGeneratedName} * ${te_lnk.linkage} = ${cast}${te_lnk.left}->${te_lnk.linkage};\n"
.assign b = b + "${ws}if ( 0 != ${te_lnk.linkage} ) {\n"