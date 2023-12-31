#!/bin/bash

gl_funcver=1
gl_funcbranch=dev
[[ -z "${gl_funcdir}" ]] && gl_funcdir="/usr/libexec/shfnlib"
##if using bash insure extglob is on
[[ -n "$BASH_VERSION" ]] && shopt -s extglob

#[of]:base
. "${gl_funcdir}/funclib-1/base/argexist-1.0.0.sh"
#[l]:prod-1  argexist:funclib-1/base/argexist-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/array-1.0.0.sh"
#[l]:prod-1  array:funclib-1/base/array-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/die-1.0.0.sh"
#[l]:prod-1  die:funclib-1/base/die-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/errorlevel-1.0.0.sh"
#[l]:prod-1  errorlevel:funclib-1/base/errorlevel-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/file-1.0.0.sh"
#[l]:prod-1  file:funclib-1/base/file-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/fn-1.0.0.sh"
#[l]:prod-1  fn:funclib-1/base/fn-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/hash-1.1.2.sh"
#[l]:prod-1  hash:funclib-1/base/hash-1.1.2.sh
. "${gl_funcdir}/funclib-1/base/msgdbg-1.0.0.sh"
#[l]:prod-1  msgdbg:funclib-1/base/msgdbg-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/string-1.1.0.sh"
#[l]:prod-1  string:funclib-1/base/string-1.1.0.sh
. "${gl_funcdir}/funclib-1/base/test-1.0.0.sh"
#[l]:prod-1  test:funclib-1/base/test-1.0.0.sh
. "${gl_funcdir}/funclib-1/base/uniqname-1.0.0.sh"
#[l]:prod-1  uniqname:funclib-1/base/uniqname-1.0.0.sh
#[cf]
#[of]:main
fn_AtomicLock=". \"${gl_funcdir}/funclib-1/main/fn_AtomicLock-1.0.0.sh\""
#[l]:prod-1  fn_AtomicLock:funclib-1/main/fn_AtomicLock-1.0.0.sh
fn_CheckHeaderFooter=". \"${gl_funcdir}/funclib-1/main/fn_CheckHeaderFooter-1.0.0.sh\""
#[l]:prod-1  fn_CheckHeaderFooter:funclib-1/main/fn_CheckHeaderFooter-1.0.0.sh
fn_CheckScriptBasedir=". \"${gl_funcdir}/funclib-1/main/fn_CheckScriptBasedir-1.0.0.sh\""
#[l]:prod-1  fn_CheckScriptBasedir:funclib-1/main/fn_CheckScriptBasedir-1.0.0.sh
fn_CheckScriptProgdir=". \"${gl_funcdir}/funclib-1/main/fn_CheckScriptProgdir-1.0.0.sh\""
#[l]:prod-1  fn_CheckScriptProgdir:funclib-1/main/fn_CheckScriptProgdir-1.0.0.sh
fn_CompareTime=". \"${gl_funcdir}/funclib-1/main/fn_CompareTime-1.0.0.sh\""
#[l]:prod-1  fn_CompareTime:funclib-1/main/fn_CompareTime-1.0.0.sh
fn_DisplayUsage=". \"${gl_funcdir}/funclib-1/main/fn_DisplayUsage-1.0.0.sh\""
#[l]:prod-1  fn_DisplayUsage:funclib-1/main/fn_DisplayUsage-1.0.0.sh
fn_FilePathBaseExtSplit=". \"${gl_funcdir}/funclib-1/main/fn_FilePathBaseExtSplit-1.0.0.sh\""
#[l]:prod-1  fn_FilePathBaseExtSplit:funclib-1/main/fn_FilePathBaseExtSplit-1.0.0.sh
fn_FileSizeClip=". \"${gl_funcdir}/funclib-1/main/fn_FileSizeClip-1.0.0.sh\""
#[l]:prod-1  fn_FileSizeClip:funclib-1/main/fn_FileSizeClip-1.0.0.sh
fn_FormatDos2Unix=". \"${gl_funcdir}/funclib-1/main/fn_FormatDos2Unix-1.0.1.sh\""
#[l]:prod-1  fn_FormatDos2Unix:funclib-1/main/fn_FormatDos2Unix-1.0.1.sh
fn_FormatTime=". \"${gl_funcdir}/funclib-1/main/fn_FormatTime-1.0.0.sh\""
#[l]:prod-1  fn_FormatTime:funclib-1/main/fn_FormatTime-1.0.0.sh
fn_FormatUnix2Dos=". \"${gl_funcdir}/funclib-1/main/fn_FormatUnix2Dos-1.0.0.sh\""
#[l]:prod-1  fn_FormatUnix2Dos:funclib-1/main/fn_FormatUnix2Dos-1.0.0.sh
fn_GetTime=". \"${gl_funcdir}/funclib-1/main/fn_GetTime-1.0.1.sh\""
#[l]:prod-1  fn_GetTime:funclib-1/main/fn_GetTime-1.0.1.sh
fn_GlobalUsage=". \"${gl_funcdir}/funclib-1/main/fn_GlobalUsage-1.0.0.sh\""
#[l]:prod-1  fn_GlobalUsage:funclib-1/main/fn_GlobalUsage-1.0.0.sh
fn_ResolveProgdir=". \"${gl_funcdir}/funclib-1/main/fn_ResolveProgdir-1.0.0.sh\""
#[l]:prod-1  fn_ResolveProgdir:funclib-1/main/fn_ResolveProgdir-1.0.0.sh
fn_SetVars=". \"${gl_funcdir}/funclib-1/main/fn_SetVars-1.0.0.sh\""
#[l]:prod-1  fn_SetVars:funclib-1/main/fn_SetVars-1.0.0.sh
fn_ShiftTime=". \"${gl_funcdir}/funclib-1/main/fn_ShiftTime-1.0.0.sh\""
#[l]:prod-1  fn_ShiftTime:funclib-1/main/fn_ShiftTime-1.0.0.sh
fn_VerifyDir=". \"${gl_funcdir}/funclib-1/main/fn_VerifyDir-1.0.0.sh\""
#[l]:prod-1  fn_VerifyDir:funclib-1/main/fn_VerifyDir-1.0.0.sh
#[cf]
#[of]:inline
. "${gl_funcdir}/funclib-1/inline/inline-1.0.0.sh"
#[l]:prod-1  inline:funclib-1/inline/inline-1.0.0.sh
#[cf]
#[of]:compat
#[cf]
# vim:number:tabstop=2:shiftwidth=2:autoindent:foldmethod=marker:foldlevel=0:foldmarker=#[of]\:,#[cf]
