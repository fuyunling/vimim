﻿" ======================================================
"               " VimIM —— Vim 中文輸入法 "
" ------------------------------------------------------
"   VimIM -- Input Method by Vim, of Vim, for Vimmers
" ======================================================

let $VimIM = " easter egg:"" vimim<C-6><C-6> vimimrc<C-6><C-6>
let $VimIM = " $Date$"
let $VimIM = " $Revision$"
let s:url  = " http://vim.sf.net/scripts/script.php?script_id=2506"
let s:url .= " http://vimim.googlecode.com/svn/vimim/vimim.vim.html"
let s:url .= " http://code.google.com/p/vimim/source/list"
let s:url .= " http://groups.google.com/group/vimim"
let s:url .= " http://vimim.googlecode.com/svn/vimim/vimim.html"
let s:url .= " vimim@googlegroups.com"

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin as an independent Input Method.
"  (1) input of Chinese without mode change:  OneKey == MidasTouch
"  (2) slash search of Chinese without typing Chinese
"  (3) support 4 clouds: Google/Baidu/Sogou/QQ cloud input
"  (4) support huge datafile if python interface to Vim is used
"
" "VimIM Installation"
"  (1) drop this vim script to plugin/:    plugin/vimim.vim
"  (2) [option] drop a standard cjk file:  plugin/vimim.cjk.txt
"  (3) [option] drop a standard directory: plugin/vimim/pinyin/
"  (4) [option] drop a English  datafile:  plugin/vimim.txt
"  (5) [option] drop a python2  database:  plugin/vimim.pinyin.db
"
" "VimIM Usage"
"  (1) play with cloud, without datafile, with python or wget/curl
"      open vim, type i, type <C-\> to open; type <C-\> to close
"  (2) play with OneKey, with cjk standard file installed:
"      open vim, type i, type sssss <C-6>, <Space>, 6, <Space> ...

" ============================================= }}}
let s:VimIM += [" ====  initialization   ==== {{{"]
" =================================================
if exists("b:loaded_vimim") || &cp || v:version<700
    finish
endif
scriptencoding utf-8
let b:loaded_vimim = 1
let s:path = expand("<sfile>:p:h")."/"

function! s:vimim_frontend_initialization()
    sil!call s:vimim_set_shuangpin()
    sil!call s:vimim_set_keycode()
    sil!call s:vimim_set_special_im_property()
    sil!call s:vimim_set_cursor_punctuation()
    sil!call s:vimim_set_omni_color()
endfunction

function! s:vimim_backend_initialization()
    if exists("s:vimim_backend_initialization")
        return
    else
        let s:vimim_backend_initialization = 1
    endif
    sil!call s:vimim_super_reset()
    sil!call s:vimim_initialize_encoding()
    sil!call s:vimim_initialize_session()
    sil!call s:vimim_initialize_ui()
    sil!call s:vimim_initialize_i_setting()
    sil!call s:vimim_dictionary_chinese()
    sil!call s:vimim_dictionary_punctuation()
    sil!call s:vimim_dictionary_im_keycode()
    sil!call s:vimim_scan_cjk_file()
    sil!call s:vimim_scan_english_datafile()
    if len(s:vimim_mycloud) > 1
        sil!call s:vimim_scan_backend_mycloud()
    else
        sil!call s:vimim_scan_backend_embedded()
        sil!call s:vimim_scan_backend_cloud()
    endif
    sil!call s:vimim_set_keycode()
endfunction

function! s:vimim_initialize_session()
    let s:seamless_positions = []
    let s:smart_single_quotes = 1
    let s:smart_double_quotes = 1
    let s:quanpin_table = {}
    let s:shuangpin_table = {}
    let s:shuangpin_keycode_chinese = {}
    let s:current_positions = [0,0,1,0]
    let s:start_row_before = 0
    let s:start_column_before = 1
    let s:scriptnames_output = 0
    let az_list = range(char2nr('a'), char2nr('z'))
    let AZ_list = range(char2nr('A'), char2nr('Z'))
    let s:az_list = map(az_list, "nr2char(".'v:val'.")")
    let s:AZ_list = map(AZ_list, "nr2char(".'v:val'.")")
    let s:Az_list = s:az_list + s:AZ_list
    let s:valid_keys = s:az_list
    let s:valid_key = 0
    let s:abcd = "'abcdvfgsz"
    let s:qwerty = split('pqwertyuio','\zs')
    let s:chinese_punctuation = s:vimim_chinese_punctuation % 2
    let s:horizontal_display = s:vimim_custom_label>0 ? 5 : 0
endfunction

function! s:vimim_initialize_ui()
    let s:ui = {}
    let s:ui.im = ''
    let s:ui.root = ''
    let s:ui.keycode = ''
    let s:ui.statusline = ''
    let s:ui.has_dot = 0
    let s:ui.frontends = []
    let s:backend = {}
    let s:backend.directory = {}
    let s:backend.datafile  = {}
    let s:backend.cloud     = {}
endfunction

function! s:vimim_one_backend_hash()
    let one_backend_hash = {}
    let one_backend_hash.root = ''
    let one_backend_hash.im = ''
    let one_backend_hash.name = ''
    let one_backend_hash.chinese = ''
    let one_backend_hash.directory = ''
    let one_backend_hash.lines = []
    let one_backend_hash.keycode = "[0-9a-z'.]"
    return one_backend_hash
endfunction

function! s:vimim_dictionary_im_keycode()
    let s:im_keycode = {}
    let keys  = split('pinyin hangul xinhua quick wubi')
    let keys += split('sogou qq google baidu mycloud')
    for key in keys
        let s:im_keycode[key] = "[.'0-9a-z]"
    endfor
    let keys = split('wu nature zhengma cangjie taijima')
    for key in keys
        let s:im_keycode[key] = "[.'a-z]"
    endfor
    let s:im_keycode.yong     = "[.'a-z;/]"
    let s:im_keycode.erbi     = "[.'a-z,;/]"
    let s:im_keycode.array30  = "[.,0-9a-z;/]"
    let s:im_keycode.phonetic = "[.,0-9a-z;/]"
    let s:im_keycode.boshiamy = "[][a-z'.,]"
    let keys  = copy(keys(s:im_keycode))
    let keys += split('pinyin_sogou pinyin_quote_sogou pinyin_huge')
    let keys += split('pinyin_fcitx pinyin_canton pinyin_hongkong')
    let keys += split('wubijd wubihf wubi98 wubi2000')
    let s:all_vimim_input_methods = copy(keys)
endfunction

function! s:vimim_set_keycode()
    let keycode = s:backend[s:ui.root][s:ui.im].keycode
    if !empty(s:vimim_shuangpin)
        let keycode = s:shuangpin_keycode_chinese.keycode
    endif
    let s:valid_key = copy(keycode)
    let character_string = ""
    let i = 0
    while i < 16*16
        let char = nr2char(i)
        if char =~# keycode
            let character_string .= char
        endif
        let i += 1
    endwhile
    let s:valid_keys = split(character_string, '\zs')
endfunction

" ============================================= }}}
let s:VimIM += [" ====  customization    ==== {{{"]
" =================================================

function! s:vimim_initialize_global()
    let G = []
    let s:vimimrc = []
    call add(G, "g:vimim_debug")
    call add(G, "g:vimim_chinese_input_mode")
    call add(G, "g:vimim_backslash_close_pinyin")
    call add(G, "g:vimim_ctrl_space_to_toggle")
    call add(G, "g:vimim_ctrl_h_to_toggle")
    call add(G, "g:vimim_data_file")
    call add(G, "g:vimim_data_directory")
    call add(G, "g:vimim_hjkl_directory")
    call add(G, "g:vimim_imode_pinyin")
    call add(G, "g:vimim_shuangpin")
    call add(G, "g:vimim_latex_suite")
    call add(G, "g:vimim_custom_menu")
    call add(G, "g:vimim_custom_label")
    call add(G, "g:vimim_onekey_is_tab")
    call add(G, "g:vimim_more_candidates")
    call add(G, "g:vimim_toggle_list")
    call add(G, "g:vimim_mycloud")
    call add(G, "g:vimim_cloud")
    call s:vimim_set_global_default(G, 0)
    let G = []
    call add(G, "g:vimim_chinese_punctuation")
    call add(G, "g:vimim_digit_4corner")
    call add(G, "g:vimim_custom_color")
    call add(G, "g:vimim_search_next")
    call s:vimim_set_global_default(G, 1)
    let s:onekey = 0
    let s:im_toggle = 0
    let s:frontends = []
    let s:loops = {}
    let s:numbers = {}
    let s:quantifiers = {}
    let s:pumheight = &pumheight
    let s:pumheight_saved = &pumheight
    let s:chinese_input_mode = 'onekey'
    if empty(s:vimim_chinese_input_mode)
        let s:vimim_chinese_input_mode = 'dynamic'
    endif
    if s:vimim_data_directory[-1:] != "/"
        let s:vimim_data_directory .= "/"
    endif
    if s:vimim_hjkl_directory[-1:] != "/"
        let s:vimim_hjkl_directory .= "/"
    endif
    let s:mahjong = split("囍發萬中 春夏秋冬 东南西北 梅兰竹菊")
endfunction

function! s:vimim_set_global_default(options, default)
    for variable in a:options
        let comment = '" '
        let default = a:default
        if exists(variable)
            let value = eval(variable)
            if value!=default || type(value)==1
                let comment = '  '
            endif
            let default = string(value)
        endif
        let option = ':let ' . variable .' = '. default .' '
        call add(s:vimimrc, comment . option)
        let s_variable = substitute(variable,"g:","s:",'')
        if exists(variable)
            exe 'let '. s_variable .'='. variable
            exe 'unlet! ' . variable
        else
            exe 'let '. s_variable .'='. a:default
        endif
    endfor
endfunction

function! s:vimim_initialize_local()
    let hjkl = simplify(s:path . '../../../hjkl/')
    if isdirectory(hjkl)
        let g:vimim_debug = 1
        let g:vimim_imode_pinyin = 2
        let g:vimim_onekey_is_tab = 2
        let g:vimim_cloud = 'google,baidu,sogou,qq'
        let g:vimim_hjkl_directory = hjkl
        let g:vimim_custom_color = 0
        call g:vimim_default_omni_color()
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  easter eggs      ==== {{{"]
" =================================================

function! s:vimim_easter_chicken(keyboard)
    if a:keyboard ==# "vim" || a:keyboard =~# "^vimim"
        try
            return eval("s:vimim_egg_" . a:keyboard . "()")
        catch
            call s:debug('alert', 'egg=', a:keyboard, v:exception)
        endtry
    endif
    return []
endfunction

function! s:vimim_egg_vimimrc()
    return sort(copy(s:vimimrc))
endfunction

function! s:vimim_egg_vimimvim()
    let filter = "strpart(" . 'v:val' . ", 0, 29)"
    return map(copy(s:VimIM), filter)
endfunction

function! s:vimim_egg_vimimgame()
    return s:mahjong
endfunction

function! s:vimim_egg_vimimclouds()
    return s:vimim_get_cloud_all('woyouyigemeng')
endfunction

function! s:vimim_egg_vim()
    let eggs  = ["vi    文本編輯器"]
    let eggs += ["vim   最牛文本編輯器"]
    let eggs += ["vim   精力"]
    let eggs += ["vim   生氣"]
    let eggs += ["vimim 中文輸入法"]
    return eggs
endfunction

function! s:vimim_egg_vimimhelp()
    let eggs = []
    let url = split(s:url)
    call add(eggs, '官方网址 ' . get(url,0) . ' ' )
    call add(eggs, '最新程式 ' . get(url,1) . ' ' )
    call add(eggs, '更新报告 ' . get(url,2) . ' ' )
    call add(eggs, '新闻论坛 ' . get(url,3) . ' ' )
    call add(eggs, '最新主页 ' . get(url,4) . ' ' )
    call add(eggs, '论坛邮箱 ' . get(url,5) . ' ' )
    return eggs
endfunction

function! s:vimim_egg_vimim()
    let eggs = []
    let today = s:vimim_imode_today_now('itoday')
    let option = s:vimim_chinese('datetime') . s:colon . today
    call add(eggs, option)
    let option = "os"
        if has("win32unix") | let option = "cygwin"
    elseif has("win32")     | let option = "Windows32"
    elseif has("win64")     | let option = "Windows64"
    elseif has("unix")      | let option = "unix"
    elseif has("macunix")   | let option = "macunix" | endif
    let option .= "_" . &term
    let computer = s:vimim_chinese('computer') . s:colon
    call add(eggs, computer . option)
    let revision = s:vimim_chinese('revision') . s:colon
    let option = get(split($VimIM),1)
    let option = empty(option) ? "" : "vimim.vim=" . option
    let vim = v:progname . "=" . v:version . s:space
    call add(eggs, revision . vim . option)
    let encoding = s:vimim_chinese('encoding') . s:colon
    call add(eggs, encoding . &encoding . s:space . &fileencodings)
    if has("gui_running")
        let font = empty(&guifontwide) ? &guifont : &guifontwide
        let option = s:vimim_chinese('font') . s:colon . font
        call add(eggs, option)
    endif
    let option = s:vimim_chinese('env') . s:colon . v:lc_time
    call add(eggs, option)
    let im = s:vimim_statusline()
    let toggle = "i_Ctrl-Bslash"
    if s:vimim_ctrl_space_to_toggle == 1
        let toggle = "toggle_with_Ctrl-Space"
    elseif s:vimim_onekey_is_tab > 1
        let toggle = "Tab_as_MidasTouch_NonStop"
        let im  = s:vimim_chinese('onekey') . s:space
        let im .= s:ui.statusline . s:space . "VimIM"
    endif
    let option = s:vimim_chinese('style') . s:colon . toggle
    call add(eggs, option)
    let database = s:vimim_chinese('database') . s:colon
    if !empty(s:english_filename)
        let ciku = database . s:vimim_chinese('english') . database
        call add(eggs, ciku . s:english_filename)
    endif
    if !empty(s:cjk_filename)
        let ciku  = database . s:vimim_chinese('standard')
        let ciku .= s:vimim_chinese('cjk') . s:colon
        call add(eggs, ciku . s:cjk_filename)
    endif
    let input = s:vimim_chinese('input')
    if len(s:ui.frontends) > 0
        let vimim_toggle_list = "english"
        for frontend in s:ui.frontends
            let ui_root = get(frontend, 0)
            let ui_im = get(frontend, 1)
            let vimim_toggle_list .= "," . ui_im
            let datafile = s:backend[ui_root][ui_im].name
            let mass = datafile=~'db' ? 'mass' : ui_root
            let ciku = database . s:vimim_chinese(mass) . database
            call add(eggs, ciku . datafile)
        endfor
    endif
    if len(im) > 0
        let option = input . s:colon . im
        call add(eggs, option)
    endif
    if len(s:ui.frontends) > 1
        let option  = s:vimim_chinese('toggle') . s:colon
        let option .= ":let g:vimim_toggle_list='"
        let option .= vimim_toggle_list . "'"
        call add(eggs, option)
    endif
    let online  = s:vimim_chinese('online') . s:colon
    if s:vimim_cloud > -1
        let option  = online . s:vimim_chinese(s:cloud_default)
        let option .= s:vimim_chinese('cloud') . input . s:space
        let option .= ":let g:vimim_cloud='" . s:vimim_cloud."'"
        call add(eggs, option)
    endif
    if len(s:vimim_mycloud) > 1
        let option  = online . s:vimim_chinese('mycloud') . s:space
        let option .= ":let g:vimim_mycloud='".s:vimim_mycloud."'"
        call add(eggs, option)
    endif
    if !empty(s:vimim_check_http_executable())
        let tool = s:vimim_chinese('tool') . s:colon
        let title = s:http_executable=~'Python' ? '' : 'HTTP executable: '
        let option = tool . title . s:http_executable
        call add(eggs, option)
    endif
    return map(eggs, 'v:val . " "')
endfunction

function! s:vimim_get_hjkl(keyboard)
    let keyboard = a:keyboard
    " [visual] " vimim_visual_ctrl6: highlighted multiple cjk
    if keyboard =~ 'u\d\d\d\d\d'
        let s:show_me_not = -7
        let chinese = substitute(getreg('"'),'[\x00-\xff]','','g')
        return split(chinese, '\zs')
    endif
    " [unicode] support direct unicode/gb/big5 input
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    if ddddd > 8080
        let lines = []
        for i in range(99)
            call add(lines, nr2char(ddddd+i))
        endfor
        return lines
    endif
    let lines = s:vimim_easter_chicken(keyboard)
    if !empty(lines)
        " [eggs] hunt classic easter egg ... vim<C-6>
    elseif keyboard == 'vimim.'
        " [hjkl] display buffer inside the omni window
        let lines = split(getreg('"'), '\n')
    elseif keyboard=~#'^[iu]' && s:vimim_imode_pinyin>0
        " [imode] magic i: (1) English number (2) Chinese number
        if keyboard ==# 'ii' " plays mahjong at will
            let lines = s:mahjong
        elseif keyboard ==# 'itoday' || keyboard ==# 'inow'
            let lines = [s:vimim_imode_today_now(keyboard)]
        elseif keyboard =~# '^i'
            if len(keyboard) == 1
                let char_before = s:vimim_get_char_before('i')
                let lines = s:vimim_get_imode_chinese(char_before,1)
            elseif keyboard =~ '[^pqwertyuio]'
                sil!call s:vimim_onekey_english(a:keyboard, 0)
                if empty(s:english_results)
                    let lines = s:vimim_imode_number(keyboard)
                endif
            endif
        elseif keyboard == 'u' && empty(s:cjk_filename)
            let unicode = "一 圣 性 楊 版 答 葬 走 隐"
            let lines = split(unicode)
        endif
    elseif keyboard !~ "db"
        " [poem] check entry in special directories first
        let datafile = s:vimim_check_filereadable(keyboard)
        if !empty(datafile)
            let lines = s:vimim_readfile(datafile)
        endif
    endif
    let s:show_me_not = !empty(lines) ? 1 : 0
    return lines
endfunction

function! s:vimim_hjkl_rotation(matched_list)
    let lines = a:matched_list
    if empty(lines)
        return []
    endif
    let max = max(map(copy(lines), 'strlen(v:val)')) + 1
    let multibyte = 1
    if match(lines,'\w') < 0
        " rotation makes more sense for cjk
        let multibyte = s:multibyte
    endif
    let results = []
    for line in lines
        let spaces = ''
        let gap = (max-len(line))/multibyte
        if gap > 0
            for i in range(gap)
                let spaces .= s:space
            endfor
        endif
        let line .= spaces
        call add(results, line)
    endfor
    let rotations = []
    for i in range(max/multibyte)
        let column = ''
        for line in reverse(copy(results))
            let line = get(split(line,'\zs'), i)
            if empty(line)
                continue
            else
                let column .= line
            endif
        endfor
        call add(rotations, column)
    endfor
    return rotations
endfunction

function! s:vimim_chinese_rotation() range abort
    sil!call s:vimim_backend_initialization()
    :%s#\s*\r\=$##
    let lines = getline(a:firstline, a:lastline)
    let lines = s:vimim_hjkl_rotation(lines)
    if !empty(lines)
        :%d
        for line in lines
            put=line
        endfor
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  /search          ==== {{{"]
" =================================================

function! g:vimim_search_next()
    let english = @/
    if english =~ '\<' && english =~ '\>'
        let english = substitute(english,'[<>\\]','','g')
    endif
    let results = []
    if len(english) > 1 && len(english) < 24
    \&& english =~ '\w' && english !~ '\W' && english !~ '_'
    \&& v:errmsg =~# english && v:errmsg =~# '^E486: '
        try
            let results = s:vimim_search_chinese_by_english(english)
        catch
            call s:debug('alert', 'slash search /', v:exception)
        endtry
    endif
    if !empty(results)
        let results = split(substitute(join(results),'\w','','g'))
        let slash = join(results[0:5], '\|')
        let @/ = slash
        if empty(search(slash,'nw'))
            let @/ = english
        endif
    endif
    echon "/" . english
    let v:errmsg = ""
endfunction

function! s:vimim_search_chinese_by_english(keyboard)
    sil!call s:vimim_backend_initialization()
    let keyboard = tolower(a:keyboard)
    let results = []
    " 1/3 first try search from cloud/mycloud
    if s:vimim_cloud =~ 'search'
        " => slash search from the default cloud
        let results = s:vimim_get_cloud(keyboard, s:cloud_default)
    elseif !empty(s:mycloud)
        " => slash search from mycloud
        let results = s:vimim_get_mycloud_plugin(keyboard)
    endif
    if !empty(results)
        return results
    endif
    " 2/3 search unicode or cjk => slash search unicode /u808f
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    if empty(ddddd) && !empty(s:cjk_filename)
        " => slash search cjk /m7712x3610j3111 /muuqwxeyqpjeqqq
        let keyboards = s:vimim_slash_search_block(keyboard)
        if len(keyboards) > 0
            for keyboard in keyboards
                let chars = s:vimim_cjk_match(keyboard)
                if len(keyboards) == 1
                    let results = copy(chars)
                elseif len(chars) > 0
                    let collection = "[" . join(chars,'') . "]"
                    call add(results, collection)
                endif
            endfor
            if len(keyboards) > 1
                let results = [join(results,'')]
            endif
        endif
    else
        let results = [nr2char(ddddd)]
    endif
    if !empty(results)
        return results
    endif
    " 3/3 search local datafiles => slash search english: /horse
    if keyboard =~ '^\l\+' && keyboard !~ '\L'
        let s:english_results = []
        sil!call s:vimim_onekey_english(a:keyboard, 1)
    endif
    " => slash search from local datafile or directory
    let results = s:vimim_embedded_backend_engine(keyboard,1)
    call extend(results, s:english_results, 0)
    return results
endfunction

function! s:vimim_slash_search_block(keyboard)
    " /muuqwxeyqpjeqqq  =>  shortcut   /search
    " /m7712x3610j3111  =>  standard   /search
    " /ma77xia36ji31    =>  free-style /search
    let results = []
    let keyboard = a:keyboard
    while len(keyboard) > 1
        let keyboard2 = s:vimim_cjk_sentence_match(keyboard)
        if empty(keyboard2)
            break
        else
            call add(results, keyboard2)
            let keyboard = strpart(keyboard,len(keyboard2))
        endif
    endwhile
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  chinese imode    ==== {{{"]
" =================================================

function! s:vimim_build_numbers_hash()
    if empty(s:numbers)
        let s:numbers.1 = "一壹⑴①甲"
        let s:numbers.2 = "二贰⑵②乙"
        let s:numbers.3 = "三叁⑶③丙"
        let s:numbers.4 = "四肆⑷④丁"
        let s:numbers.5 = "五伍⑸⑤戊"
        let s:numbers.6 = "六陆⑹⑥己"
        let s:numbers.7 = "七柒⑺⑦庚"
        let s:numbers.8 = "八捌⑻⑧辛"
        let s:numbers.9 = "九玖⑼⑨壬"
        let s:numbers.0 = "〇零⑽⑩癸"
    endif
endfunction

function! s:vimim_get_antonym_list()
    let antonym  = " ，。 “” ‘’ （） 【】 〖〗 《》"
    let antonym .= " 加减乘除 危安 胜败 凶吉 真假 石金 "
    return split(antonym)
endfunction

function! s:vimim_get_imode_chinese(char_before, insert)
    if empty(s:loops)
        let antonyms = s:vimim_get_antonym_list()
        let numbers  = s:vimim_get_numbers_list()
        let imode_list = s:mahjong + numbers + antonyms
        for loop in imode_list
            let loops = split(loop,'\zs')
            for i in range(len(loops))
                let j = i==len(loops)-1 ? 0 : i+1
                let s:loops[loops[i]] = loops[j]
            endfor
        endfor
    endif
    let results = []
    let key = a:char_before
    if has_key(s:loops, key)
        let start = key
        let next = ""
        while start != next
            let next = s:loops[key]
            call add(results, next)
            let key = next
        endwhile
    elseif a:insert > 0
        let i_in_english = "我 你 妳 他 她 它"
        let results = split(i_in_english)
    endif
    return results
endfunction

function! s:vimim_get_numbers_list()
    let items = []
    call s:vimim_build_numbers_hash()
    for i in range(len(s:numbers))
        call add(items, split(s:numbers[i],'\zs'))
    endfor
    let numbers = []
    for j in range(len(get(items,0)))
        let number = ""
        for line in items
            let number .= get(line,j)
        endfor
        call add(numbers, number)
    endfor
    return numbers
endfunction

let s:translators = {}
function! s:translators.translate(english) dict
    let inputs = split(a:english)
    return join(map(inputs,'get(self.dict,tolower(v:val),v:val)'), '')
endfunction

function! s:vimim_imode_today_now(keyboard)
    let results = []
    call add(results, strftime("%Y"))
    call add(results, 'year')
    call add(results, substitute(strftime("%m"),'^0','',''))
    call add(results, 'month')
    call add(results, substitute(strftime("%d"),'^0','',''))
    call add(results, 'day')
    if a:keyboard ==# 'itoday'
        call add(results, s:space)
        call add(results, strftime("%A"))
    elseif a:keyboard ==# 'inow'
        call add(results, substitute(strftime("%H"),'^0','',''))
        call add(results, 'hour')
        call add(results, substitute(strftime("%M"),'^0','',''))
        call add(results, 'minute')
        call add(results, substitute(strftime("%S"),'^0','',''))
        call add(results, 'second')
    endif
    let ecdict = {}
    let ecdict.sunday    = "星期日"
    let ecdict.monday    = "星期一"
    let ecdict.tuesday   = "星期二"
    let ecdict.wednesday = "星期三"
    let ecdict.thursday  = "星期四"
    let ecdict.friday    = "星期五"
    let ecdict.saturday  = "星期六"
    let ecdict.year      = "年"
    let ecdict.month     = "月"
    let ecdict.day       = "日"
    let ecdict.hour      = "时"
    let ecdict.minute    = "分"
    let ecdict.second    = "秒"
    let chinese = copy(s:translators)
    let chinese.dict = ecdict
    return chinese.translate(join(results))
endfunction

function! s:vimim_imode_number(keyboard)
    let keyboard = a:keyboard
    let ii = keyboard[0:1] " sample: i88 ii88 isw8ql iisw8ql
    let keyboard = ii==#'ii' ? keyboard[2:] : keyboard[1:]
    let dddl = keyboard=~#'^\d*\l\{1}$' ? keyboard[:-2] : keyboard
    let keyboards = split(dddl, '\ze')
    let number = ""
    if empty(s:quantifiers)
        call s:vimim_build_quantifier_hash()
    endif
    for char in keyboards
        if has_key(s:quantifiers, char)
            let quantifier_list = split(s:quantifiers[char], '\zs')
            let chinese = get(quantifier_list, 0)
            if ii ==# 'ii' && char =~ '[0-9sbq]'
                let chinese = get(quantifier_list, 1)
            endif
        endif
        let number .= chinese
    endfor
    if empty(number)
        return []
    endif
    let numbers = [number]
    let last_char = keyboard[-1:]
    if !empty(last_char) && has_key(s:quantifiers, last_char)
        let quantifier_list = split(s:quantifiers[last_char], '\zs')
        if keyboard =~# '^[ds]\=\d*\l\{1}$'
            if keyboard =~# '^[ds]'
                let number = strpart(number,0,len(number)-s:multibyte)
            endif
            let numbers = map(copy(quantifier_list), 'number . v:val')
        elseif keyboard =~# '^\d*$' && len(keyboards)<2 && ii != 'ii'
            let numbers = quantifier_list
        endif
    endif
    return numbers
endfunction

function! s:vimim_build_quantifier_hash()
    call s:vimim_build_numbers_hash()
    let s:quantifiers = copy(s:numbers)
    let s:quantifiers.a = "秒"
    let s:quantifiers.b = "百佰步把包杯本笔部班"
    let s:quantifiers.c = "次餐场串处床"
    let s:quantifiers.d = "第度点袋道滴碟顶栋堆对朵堵顿"
    let s:quantifiers.e = "亿"
    let s:quantifiers.f = "分份发封付副幅峰方服"
    let s:quantifiers.g = "个根股管"
    let s:quantifiers.h = "毫行盒壶户回"
    let s:quantifiers.i = "毫"
    let s:quantifiers.j = "斤家具架间件节剂具捲卷茎记"
    let s:quantifiers.k = "克口块棵颗捆孔"
    let s:quantifiers.l = "里粒类辆列轮厘领缕"
    let s:quantifiers.m = "米名枚面门"
    let s:quantifiers.n = "年"
    let s:quantifiers.o = "度"
    let s:quantifiers.p = "磅盆瓶排盘盆匹片篇撇喷"
    let s:quantifiers.q = "千仟群"
    let s:quantifiers.r = "日"
    let s:quantifiers.s = "十拾时升艘扇首双所束手"
    let s:quantifiers.t = "天吨条头通堂趟台套桶筒贴"
    let s:quantifiers.u = "微"
    let s:quantifiers.w = "万位味碗窝晚"
    let s:quantifiers.x = "席些项"
    let s:quantifiers.y = "月叶亿"
    let s:quantifiers.z = "种只张株支枝盏座阵桩尊则站幢宗兆"
endfunction

" ============================================= }}}
let s:VimIM += [" ====  punctuation      ==== {{{"]
" =================================================

function! s:vimim_dictionary_punctuation()
    let s:punctuations = {}
    let s:punctuations['{'] = "〖"  | let s:space = "　"
    let s:punctuations['}'] = "〗"  | let s:colon = "："
    let s:punctuations['<'] = "《"  | let s:left  = "【"
    let s:punctuations['>'] = "》"  | let s:right = "】"
    let s:punctuations['@'] = s:space
    let s:punctuations[':'] = s:colon
    let s:punctuations['['] = s:left
    let s:punctuations[']'] = s:right
    let s:punctuations['('] = "（"
    let s:punctuations[')'] = "）"
    let s:punctuations['#'] = "＃"
    let s:punctuations['&'] = "＆"
    let s:punctuations['%'] = "％"
    let s:punctuations['$'] = "￥"
    let s:punctuations['!'] = "！"
    let s:punctuations['~'] = "～"
    let s:punctuations['+'] = "＋"
    let s:punctuations['-'] = "－"
    let s:punctuations['='] = "＝"
    let s:punctuations[';'] = "；"
    let s:punctuations[','] = "，"
    let s:punctuations['.'] = "。"
    let s:punctuations['?'] = "？"
    let s:punctuations['*'] = "﹡"
    let s:punctuations['^'] = "……"
    let s:punctuations['_'] = "——"
    let s:evils = {}
    if empty(s:vimim_backslash_close_pinyin)
        let s:evils['\'] = "、"
    endif
    if empty(s:vimim_latex_suite)
        let s:evils["'"] = "‘’"
        let s:evils['"'] = "“”"
    endif
endfunction

function! s:vimim_set_cursor_punctuation()
    highlight  default CursorIM guifg=NONE guibg=green gui=NONE
    for char in s:valid_keys
        if has_key(s:punctuations, char)
            if s:ui.has_dot == 1
                unlet s:punctuations[char]
            elseif char !~# "[*.']"
                unlet s:punctuations[char]
            endif
        endif
    endfor
endfunction

function! s:vimim_punctuation_mapping()
    if s:chinese_punctuation > 0
        if empty(s:vimim_latex_suite)
            inoremap ' <C-R>=<SID>vimim_get_quote(1)<CR>
            inoremap " <C-R>=<SID>vimim_get_quote(2)<CR>
        endif
        if empty(s:vimim_backslash_close_pinyin)
            sil!exe 'inoremap <Bslash> ' .
            \ '<C-R>=pumvisible() ? "<C-Y>" : ""<CR>' . s:evils['\']
        endif
    else
        for _ in keys(s:evils)
            sil!exe 'iunmap '. _
        endfor
    endif
    for _ in keys(s:punctuations)
        silent!exe 'inoremap <silent> <expr> '    ._.
        \ ' <SID>vimim_chinese_punctuation_map("'._.'")'
    endfor
    return ""
endfunction

function! <SID>vimim_chinese_punctuation_map(key)
    let key = a:key
    if s:chinese_punctuation > 0
        let one_before = getline(".")[col(".")-2]
        if one_before !~ '\w' || pumvisible()
            if has_key(s:punctuations, a:key)
                let key = s:punctuations[a:key]
            endif
        endif
    endif
    if pumvisible()
        if a:key =~ "[=-]"
            if a:key =~ "[=]"
                let s:pageup_pagedown = 1
            elseif a:key =~ "[-]"
                let s:pageup_pagedown = -1
            endif
            let key = '\<C-E>\<C-R>=g:vimim()\<CR>'
        else
            let key = '\<C-Y>' . key
            if a:key =~ "[][]"
                let key = s:vimim_square_bracket(a:key)
            endif
            call g:vimim_reset_after_insert()
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_onekey_mapping_punctuation()
    if s:vimim_chinese_punctuation < 0
        return
    endif
    let special_punctuation = "[]-=.,/?;"
    let map_list = split(special_punctuation,'\zs')
    for char in s:valid_keys
        let i = index(map_list, char)
        if i > -1 && char != "."
            unlet map_list[i]
        endif
    endfor
    for _ in map_list
        sil!exe 'ino<expr> '._.' <SID>vimim_onekey_punctuation("'._.'")'
    endfor
endfunction

function! <SID>vimim_onekey_punctuation(key)
    let hjkl = a:key
    if pumvisible()
        if a:key =~ ";"
            let hjkl = '\<C-Y>\<C-R>=g:vimim_menu_to_clip()\<CR>'
        elseif a:key =~ "[][]"
            let hjkl = s:vimim_square_bracket(a:key)
        elseif a:key =~ "[/?]"
            let hjkl = s:vimim_menu_search(a:key)
        elseif a:key =~ "[-,]"
            let hjkl = '\<PageUp>'
            if &pumheight > 0
                let s:pageup_pagedown = -1
                let hjkl = '\<C-E>\<C-R>=g:vimim()\<CR>'
            endif
        elseif a:key =~ "[=.]"
            let hjkl = '\<PageDown>'
            if &pumheight > 0
                let s:pageup_pagedown = 1
                let hjkl = '\<C-E>\<C-R>=g:vimim()\<CR>'
            endif
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

function! <SID>vimim_get_quote(type)
    let key = ""
        if a:type == 1 | let key = "'"
    elseif a:type == 2 | let key = '"' | endif
    let quote = ""
    if !has_key(s:evils, key)
        return ""
    elseif pumvisible()
        let quote = '\<C-Y>'
    endif
    let pairs = split(s:evils[key], '\zs')
    if a:type == 1
        let s:smart_single_quotes += 1
        let quote .= get(pairs, s:smart_single_quotes % 2)
    elseif a:type == 2
        let s:smart_double_quotes += 1
        let quote .= get(pairs, s:smart_double_quotes % 2)
    endif
    sil!exe 'sil!return "' . quote . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  miscellaneous    ==== {{{"]
" =================================================

function! s:vimim_get_valid_im_name(im)
    let im = a:im
    if im =~ '^wubi'
        let im = 'wubi'
    elseif im =~ '^pinyin'
        let im = 'pinyin'
        if  empty(s:vimim_imode_pinyin)
            let s:vimim_imode_pinyin = 1
        endif
    elseif im !~ s:all_vimim_input_methods
        let im = 0
    endif
    return im
endfunction

function! s:vimim_set_special_im_property()
    if  s:ui.im == 'pinyin' || !empty(s:cjk_filename)
        let s:quanpin_table = s:vimim_create_quanpin_table()
    endif
    if s:backend[s:ui.root][s:ui.im].name =~# "quote"
        let s:ui.has_dot = 2  " has apostrophe in datafile
    endif
    for im in split('wu erbi yong nature boshiamy phonetic array30')
        if s:ui.im == im
            let s:ui.has_dot = 1  " has dot in datafile
            let s:vimim_chinese_punctuation = -9
            break
        endif
    endfor
endfunction

function! s:vimim_wubi_auto_input_on_the_4th(keyboard)
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
        if len(keyboard) > 4
            let start = 4*((len(keyboard)-1)/4)
            let keyboard = strpart(keyboard, start)
        endif
        let s:keyboard_list = [keyboard]
    endif
    return keyboard
endfunction

function! g:vimim_wubi_ctrl_e_ctrl_y()
    let key = ""
    if pumvisible()
        let key = '\<C-E>'
        if empty(len(get(s:keyboard_list,0))%4)
            let key = '\<C-Y>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_plugin_conflict_fix_on()
    if !exists('s:acp_sid')
        let s:acp_sid = s:vimim_getsid('autoload/acp.vim')
        if !empty(s:acp_sid)
            AcpDisable
        endif
    endif
    if !exists('s:supertab_sid')
        let s:supertab_sid = s:vimim_getsid('plugin/supertab.vim')
    endif
    if !exists('s:word_complete')
        let s:word_complete = s:vimim_getsid('plugin/word_complete.vim')
        if !empty(s:word_complete)
            call EndWordComplete()
        endif
    endif
endfunction

function! s:vimim_plugin_conflict_fix_off()
    if !empty(s:acp_sid)
        let ACPMappingDrivenkeys = [
            \ '-','_','~','^','.',',',':','!','#','=','%','$','@',
            \ '<','>','/','\','<Space>','<BS>','<CR>',]
        call extend(ACPMappingDrivenkeys, range(10))
        call extend(ACPMappingDrivenkeys, s:Az_list)
        for key in ACPMappingDrivenkeys
            exe printf('iu <silent> %s', key)
            exe printf('im <silent> %s %s<C-r>=<SNR>%s_feedPopup()<CR>',
            \ key, key, s:acp_sid)
        endfor
        AcpEnable
    endif
    if !empty(s:supertab_sid)
        let tab = s:supertab_sid
        if g:SuperTabMappingForward =~ '^<tab>$'
            exe printf("im <tab> <C-R>=<SNR>%s_SuperTab('p')<CR>", tab)
        endif
        if g:SuperTabMappingBackward =~ '^<s-tab>$'
            exe printf("im <s-tab> <C-R>=<SNR>%s_SuperTab('n')<CR>", tab)
        endif
    endif
endfunction

function! s:vimim_getsid(scriptname)
    " use s:getsid to get script sid, translate <SID> to <SNR>N_ style
    let l:scriptname = a:scriptname
    " get output of ":scriptnames" in scriptnames_output variable
    if empty(s:scriptnames_output)
        let saved_shellslash=&shellslash
        set shellslash
        redir => s:scriptnames_output
        silent scriptnames
        redir END
        let &shellslash = saved_shellslash
    endif
    for line in split(s:scriptnames_output, "\n")
        " only do non-blank lines
        if line =~ l:scriptname
            " get the first number in the line
            return matchstr(line, '\d\+')
        endif
    endfor
    return 0
endfunction

" ============================================= }}}
let s:VimIM += [" ====  user   interface ==== {{{"]
" =================================================

function! s:vimim_dictionary_chinese()
    let s:status = {}
    let s:status.onekey     = "点石成金 點石成金"
    let s:status.computer   = "电脑 電腦"
    let s:status.database   = "词库 詞庫"
    let s:status.cjk        = "字库 字庫"
    let s:status.directory  = "目录 目錄"
    let s:status.option     = "选项 選項"
    let s:status.standard   = "标准 標準"
    let s:status.encoding   = "编码 編碼"
    let s:status.env        = "环境 環境"
    let s:status.input      = "输入 輸入"
    let s:status.font       = "字体 字體"
    let s:status.static     = "静态 靜態"
    let s:status.dynamic    = "动态 動態"
    let s:status.style      = "风格 風格"
    let s:status.erbi       = "二笔 二筆"
    let s:status.wubi       = "五笔 五筆"
    let s:status.hangul     = "韩文 韓文"
    let s:status.xinhua     = "新华 新華"
    let s:status.zhengma    = "郑码 鄭碼"
    let s:status.cangjie    = "仓颉 倉頡"
    let s:status.yong       = "永码 永碼"
    let s:status.wu         = "吴语 吳語"
    let s:status.jidian     = "极点 極點"
    let s:status.haifeng    = "海峰 海峰"
    let s:status.shuangpin  = "双拼 雙拼"
    let s:status.boshiamy   = "呒虾米 嘸蝦米"
    let s:status.newcentury = "新世纪 新世紀"
    let s:status.taijima    = "太极码 太極碼"
    let s:status.abc        = "智能双打 智能雙打"
    let s:status.ms         = "微软 微軟"
    let s:status.nature     = "自然码 自然碼"
    let s:status.mixture    = "混合"
    let s:status.purple     = "紫光"
    let s:status.plusplus   = "加加"
    let s:status.flypy      = "小鹤 小鶴"
    let s:status.quick      = "速成"
    let s:status.array30    = "行列"
    let s:status.phonetic   = "注音"
    let s:status.pinyin     = "拼音"
    let s:status.revision   = "版本"
    let s:status.full_width = "全角"
    let s:status.half_width = "半角"
    let s:status.mycloud    = "自己的云 自己的雲"
    let s:status.cloud      = "云 雲"
    let s:status.toggle     = "切换 切換"
    let s:status.online     = "在线 在綫"
    let s:status.tool       = "工具"
    let s:status.sogou      = "搜狗"
    let s:status.google     = "谷歌"
    let s:status.baidu      = "百度"
    let s:status.qq         = "QQ"
    let s:status.datafile   = "文件"
    let s:status.mass       = "海量"
    let s:status.datetime   = "日期"
    let s:status.english    = "英文"
    let s:status.chinese    = "中文"
endfunction

function! s:vimim_chinese(key)
    let chinese = a:key
    if has_key(s:status, chinese)
        let twins = split(s:status[chinese])
        let chinese = get(twins,0)
        if len(twins) > 1 && s:vimim_imode_pinyin < 2
            let chinese = get(twins,1)
        endif
    endif
    return chinese
endfunction

function! g:vimim_default_omni_color()
    highlight! PmenuSbar  NONE
    highlight! PmenuThumb NONE
    highlight! Pmenu      NONE
    highlight! link PmenuSel Title
endfunction

function! s:vimim_set_omni_color()
    if s:vimim_custom_color > 0
        call g:vimim_default_omni_color()
    endif
    if s:vimim_custom_color > 1 || s:vimim_custom_label > 0
        highlight!      PmenuSel NONE
        highlight! link PmenuSel NONE
    endif
endfunction

function! s:vimim_set_keyboard_list(column_start, keyboard)
    let s:start_column_before = a:column_start
    if len(s:keyboard_list) < 2
        let s:keyboard_list = [a:keyboard]
    endif
endfunction

function! s:vimim_set_statusline()
    set laststatus=2
    if empty(&statusline)
        set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P%{IMName()}
    elseif &statusline =~ 'IMName'
        " nothing, because it is already in the statusline
    elseif &statusline =~ '\V\^%!'
        let &statusline .= '.IMName()'
    else
        let &statusline .= '%{IMName()}'
    endif
endfunction

function! IMName()
    " This function is for user-defined 'stl' 'statusline'
    if s:chinese_input_mode =~ 'onekey'
        if pumvisible()
            return s:vimim_statusline()
        endif
    elseif !empty(&omnifunc) && &omnifunc ==# 'VimIM'
        return s:vimim_statusline()
    endif
    return ""
endfunction

function! s:vimim_statusline()
    if empty(s:ui.root) || empty(s:ui.im)
        return ""
    endif
    if has_key(s:im_keycode, s:ui.im)
        let s:ui.statusline = s:backend[s:ui.root][s:ui.im].chinese
    endif
    let datafile = s:backend[s:ui.root][s:ui.im].name
    if s:ui.im =~ 'wubi'
        if datafile =~# 'wubi98'
            let s:ui.statusline .= '98'
        elseif datafile =~# 'wubi2000'
            let newcentury = s:vimim_chinese('newcentury')
            let s:ui.statusline = newcentury . s:ui.statusline
        elseif datafile =~# 'wubijd'
            let jidian = s:vimim_chinese('jidian')
            let s:ui.statusline = jidian . s:ui.statusline
        elseif datafile =~# 'wubihf'
            let haifeng = s:vimim_chinese('haifeng')
            let s:ui.statusline = haifeng . s:ui.statusline
        endif
        return s:vimim_get_chinese_im()
    endif
    if len(s:backend.datafile) > 0 || len(s:backend.directory) > 0
        if !empty(s:vimim_shuangpin)
            let s:ui.statusline .= s:space
            let s:ui.statusline .= s:shuangpin_keycode_chinese.chinese
        endif
    endif
    let clouds = split(s:vimim_cloud,',')
    let cloud_in_use = s:ui.root=='cloud' ? match(clouds,s:ui.im) : 0
    let vimim_cloud = get(clouds, cloud_in_use)
    if vimim_cloud =~ 'mixture'
        let s:ui.statusline .= s:vimim_chinese('mixture')
    elseif vimim_cloud =~ 'wubi'
        let s:ui.statusline .= s:vimim_chinese('wubi')
    elseif vimim_cloud =~ 'shuangpin'
        if vimim_cloud =~ 'abc'
            let s:ui.statusline .= s:vimim_chinese('abc')
        elseif vimim_cloud =~ 'ms'
            let s:ui.statusline .= s:vimim_chinese('ms')
        elseif vimim_cloud =~ 'plusplus'
            let s:ui.statusline .= s:vimim_chinese('plusplus')
        elseif vimim_cloud =~ 'purple'
            let s:ui.statusline .= s:vimim_chinese('purple')
        elseif vimim_cloud =~ 'flypy'
            let s:ui.statusline .= s:vimim_chinese('flypy')
        elseif vimim_cloud =~ 'nature'
            let s:ui.statusline .= s:vimim_chinese('nature')
        endif
        if vimim_cloud !~ 'abc'
            let s:ui.statusline .= s:vimim_chinese('shuangpin')
        endif
    endif
    if !empty(s:mycloud)
        let __getname = s:backend.cloud.mycloud.directory
        let s:ui.statusline .= s:space . __getname
    endif
    return s:vimim_get_chinese_im()
endfunction

function! s:vimim_get_chinese_im()
    if s:chinese_input_mode !~ 'onekey'
        let punctuation = s:vimim_chinese('half_width')
        if s:chinese_punctuation > 0
            let punctuation = s:vimim_chinese('full_width')
        endif
        let s:ui.statusline .= s:space . punctuation
    endif
    let statusline = s:left . s:ui.statusline . s:right . "VimIM"
    let input_style  = s:vimim_chinese('chinese')
    let input_style .= s:vimim_chinese(s:vimim_chinese_input_mode)
    let input_style .= statusline
    return input_style
endfunction

function! s:vimim_label_on()
    if s:vimim_custom_label < 0
        return
    endif
    let labels = range(1, s:horizontal_display)
    if s:vimim_custom_label > 0
        let s:abcd = join(labels, '')
    else
        let labels = range(10)
        let s:abcd = s:abcd[0 : &pumheight-2] . s:abcd[-1:]
        let abcd_list = split(s:abcd, '\zs')
        if s:chinese_input_mode =~ 'onekey'
            let labels += abcd_list
            call remove(labels, match(labels,"'"))
        else
            let labels += [";", "'"]
            for _ in abcd_list
                sil!exe 'iunmap '. _
            endfor
        endif
    endif
    for _ in labels
        silent!exe 'inoremap <silent> <expr> '  ._.
        \  ' <SID>vimim_alphabet_number_label("'._.'")'
    endfor
endfunction

function! <SID>vimim_alphabet_number_label(key)
    let key = a:key
    if pumvisible()
        let n = match(s:abcd, key)
            if key =~ '\d' | let n = key<1 ? 9 : key-1
        elseif key == ';'  | let n = 1
        elseif key == "'"  | let n = 2 | endif
        let down = repeat("\<Down>", n)
        let yes = '\<C-Y>\<C-R>=g:vimim()\<CR>'
        let key = down . yes
        let s:has_pumvisible = 1
        if s:chinese_input_mode =~ 'onekey' && a:key =~ '\d'
            call g:vimim_stop()
        else
            call g:vimim_reset_after_insert()
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_menu_search(key)
    let slash = ""
    if pumvisible()
        let slash  = '\<C-Y>\<C-R>=g:vimim_menu_search_on()\<CR>'
        let slash .= a:key . '\<CR>'
    endif
    sil!exe 'sil!return "' . slash . '"'
endfunction

function! g:vimim_menu_search_on()
    let word = s:vimim_popup_word()
    let @/ = empty(word) ? @_ : word
    let repeat_times = len(word) / s:multibyte
    let row_start = s:start_row_before
    let row_end = line('.')
    let delete_chars = ""
    if repeat_times > 0 && row_end == row_start
        let delete_chars = repeat("\<BS>", repeat_times)
    endif
    let slash = delete_chars . "\<Esc>"
    sil!call g:vimim_stop()
    sil!exe 'sil!return "' . slash . '"'
endfunction

function! s:vimim_square_bracket(key)
    let key = a:key
    if pumvisible()
        let i     = key=="]" ? 0          : -1
        let left  = key=="]" ? "\<Left>"  : ""
        let right = key=="]" ? "\<Right>" : ""
        if s:show_me_not < 1
            let backspace = '\<C-R>=g:vimim_bracket('.i.')\<CR>'
            let key = '\<C-Y>' . left . backspace . right
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_bracket(offset)
    let column_end = col('.')-1
    let column_start = s:start_column_before
    let range = column_end - column_start
    let repeat_times = range / s:multibyte
    let repeat_times += a:offset
    let row_end = line('.')
    let row_start = s:start_row_before
    let delete_char = ""
    if repeat_times > 0 && row_end == row_start
        let delete_char = repeat("\<BS>", repeat_times)
    endif
    if repeat_times < 1
        let current_line = getline(".")
        let chinese = strpart(current_line, column_start, s:multibyte)
        let delete_char = chinese
        if empty(a:offset)
            let chinese = s:left . chinese . s:right
            let delete_char = "\<Right>\<BS>" . chinese . "\<Left>"
        endif
    endif
    return delete_char
endfunction

function! <SID>vimim_esc()
    let key = '\<Esc>'
    if s:chinese_input_mode =~ 'onekey'
        sil!call g:vimim_stop()
    elseif pumvisible()
        let column_start = s:start_column_before
        let column_end = col('.') - 1
        let range = column_end - column_start
        let key = '\<C-E>' . repeat("\<BS>", range)
        sil!call s:vimim_super_reset()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_backspace()
    let key = '\<BS>'
    if pumvisible()
        let key = '\<C-E>\<BS>\<C-R>=g:vimim()\<CR>'
    endif
    sil!call s:vimim_super_reset()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_enter()
    " <Enter> triple play for OneKey and static mode:
    "  (1) single <Enter> after English ==> seamless
    "  (2) double <Enter> after English ==> <Space>
    "  (3) <Enter> after Space/Chinese  ==> <Enter>
    let one_before = getline(".")[col(".")-2]
    if one_before=~s:valid_key && !has_key(s:punctuations,one_before)
        let s:smart_enter += 1
        if s:chinese_input_mode =~ 'dynamic'
            let s:smart_enter = 1
        endif
    elseif s:chinese_input_mode =~ 'dynamic'
        let s:smart_enter = 3
    endif
    let key = pumvisible() ? "\<C-E>" : ""
    if s:smart_enter == 1
        let s:seamless_positions = getpos(".")
    else
        let key = s:smart_enter==2 ? " " : "\<CR>"
        let s:smart_enter = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_get_labeling(label)
    let fmt = '%2s '
    let labeling = a:label
    if a:label == 10 && empty(s:cjk_filename) && empty(s:hjkl_l%2)
        let labeling = "0"
    endif
    if s:chinese_input_mode =~ 'onekey'
        if s:show_me_not > 0
            let fmt = '%02s '
            if s:hjkl_l % 2 < 1
                let labeling = ""
            endif
        elseif a:label < &pumheight + 1
            let label2 = a:label<2 ? "_" : s:abcd[a:label-1]
            let labeling .= label2
        endif
        if s:hjkl_l > 0 && &pumheight < 1
            let fmt = '%02s '
        endif
    endif
    if !empty(labeling)
        let labeling = printf(fmt, labeling)
    endif
    return labeling
endfunction

" ============================================= }}}
let s:VimIM += [" ====  python interface ==== {{{"]
" =================================================

function! s:vimim_database_init()
:sil!python << EOF
def getstone(key, partition):
    isenglish = vim.eval('s:english_results')
    if partition > 0 and len(key) > 1:
        key = key[:-partition]
    if key not in db and not isenglish:
        while key and key not in db: key = key[:-1]
    return key
def getgold(key):
  if key in db:
      chinese = key + ' ' + db.get(key)
      if vim.eval("&encoding") != 'utf-8':
          chinese = unicode(chinese, 'utf-8').encode('gbk')
  else:
      chinese = key
  return chinese
EOF
endfunction

function! s:vimim_get_from_python2(input, cloud)
:sil!python << EOF
import vim, urllib2
try:
    cloud = vim.eval('a:cloud')
    input = vim.eval('a:input')
    urlopen = urllib2.urlopen(input, None, 20)
    response = urlopen.read()
    res = "'" + str(response) + "'"
    if cloud == 'qq':
        if vim.eval("&encoding") != 'utf-8':
            res = unicode(res, 'utf-8').encode('utf-8')
    elif cloud == 'google':
        if vim.eval("&encoding") != 'utf-8':
            res = unicode(res, 'unicode_escape').encode("utf8")
    elif cloud == 'baidu':
        if vim.eval("&encoding") != 'utf-8':
            res = str(response)
        else:
            res = unicode(response, 'gbk').encode('utf-8')
        vim.command("let g:baidu = %s" % res)
    vim.command("return %s" % res)
    urlopen.close()
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

function! s:vimim_get_from_python3(input, cloud)
:sil!python3 << EOF
import vim, urllib.request
try:
    cloud = vim.eval('a:cloud')
    input = vim.eval('a:input')
    urlopen = urllib.request.urlopen(input)
    response = urlopen.read()
    if cloud != 'baidu':
        res = "'" + str(response.decode('utf-8')) + "'"
    else:
        if vim.eval("&encoding") != 'utf-8':
            res = str(response)[2:-1]
        else:
            res = response.decode('gbk')
        vim.command("let g:baidu = %s" % res)
    vim.command("return %s" % res)
    urlopen.close()
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

function! g:vimim_gmail() range abort
" [dream] to send email from within the current buffer
" [usage] :call g:vimim_gmail()
" [vimrc] :let  g:gmails={'login':'','passwd':'','to':'','bcc':''}
if has('python') < 1 && has('python3') < 1
    echo 'No magic Python Interface to Vim' | return ""
endif
let firstline = a:firstline
let  lastline = a:lastline
if lastline - firstline < 1
    let firstline = 1
    let lastline = "$"
endif
let g:gmails.msg = getline(firstline, lastline)
let python = has('python3') && &relativenumber>0 ? 'python3' : 'python'
exe python . ' << EOF'
import vim
from smtplib import SMTP
from datetime import datetime
from email.mime.text import MIMEText
def vimim_gmail():
    gmails = vim.eval('g:gmails')
    vim.command('sil!unlet g:gmails.bcc')
    now = datetime.now().strftime("%A %m/%d/%Y")
    gmail_login  = gmails.get("login","")
    if len(gmail_login) < 8: return None
    gmail_passwd = gmails.get("passwd")
    gmail_to     = gmails.get("to")
    gmail_bcc    = gmails.get("bcc","")
    gmail_msg    = gmails.get("msg")
    gamil_all = [gmail_to] + gmail_bcc.split()
    msg = str("\n".join(gmail_msg))
    rfc2822 = MIMEText(msg, 'plain', 'utf-8')
    rfc2822['From'] = gmail_login
    rfc2822['To'] = gmail_to
    rfc2822['Subject'] = now
    rfc2822.set_charset('utf-8')
    try:
        gmail = SMTP('smtp.gmail.com', 587, 120)
        gmail.starttls()
        gmail.login(gmail_login, gmail_passwd[::-1])
        gmail.sendmail(gmail_login, gamil_all, rfc2822.as_string())
    finally:
        gmail.close()
vimim_gmail()
EOF
endfunction

function! s:vimim_mycloud_python_init()
:sil!python << EOF
import vim, sys, socket
BUFSIZE = 1024
def tcpslice(sendfunc, data):
    senddata = data
    while len(senddata) >= BUFSIZE:
        sendfunc(senddata[0:BUFSIZE])
        senddata = senddata[BUFSIZE:]
    if senddata[-1:] == "\n":
        sendfunc(senddata)
    else:
        sendfunc(senddata+"\n")
def tcpsend(data, host, port):
    addr = host, port
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.connect(addr)
    except Exception, inst:
        s.close()
        return None
    ret = ""
    for item in data.split("\n"):
        if item == "":
            continue
        tcpslice(s.send, item)
        cachedata = ""
        while cachedata[-1:] != "\n":
            data = s.recv(BUFSIZE)
            cachedata += data
        if cachedata == "server closed\n":
            break
        ret += cachedata
    s.close()
    return ret
def parsefunc(keyb, host="localhost", port=10007):
    src = keyb.encode("base64")
    ret = tcpsend(src, host, port)
    if type(ret).__name__ == "str":
        try:
            return ret.decode("base64")
        except Exception:
            return ""
    else:
        return ""
EOF
endfunction

function! s:vimim_mycloud_python_client(cmd, host, port)
:sil!python << EOF
try:
    HOST = vim.eval("a:host")
    PORT = int(vim.eval("a:port"))
    cmd  = vim.eval("a:cmd")
    ret = parsefunc(cmd, HOST, PORT)
    vim.command('return "%s"' % ret)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

function! s:netlog_python_init()
:sil!python << EOF
import vim, sys, socket
BUFSIZE = 1024
def udpslice(sendfunc, data, addr):
    senddata = data
    while len(senddata) >= BUFSIZE:
        sendfunc(senddata[0:BUFSIZE], addr)
        senddata = senddata[BUFSIZE:]
    if senddata[-1:] == "\n":
        sendfunc(senddata, addr)
    else:
        sendfunc(senddata+"\n", addr)
def udpsend(data, host, port):
    addr = host, port
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(1)
    try:
        s.bind(('', 0))
    except Exception, inst:
        s.close()
        return None
    ret = ""
    for item in data.split("\n"):
        if item == "":
            continue
        udpslice(s.sendto, item, addr)
    s.close()
def log_mask(level):
    pri = g_level.get(level, -1)
    if pri < 0:
        return 0
    else:
        return 1 << pri
def log_upto(level):
    pri = g_level.get(level, -1)
    return (1 <<(pri+1) ) - 1
def checkmask(level):
    if log_mask(level) & g_mask:
        return True
    else:
        return False
g_level = {'emerg':0,    #  system is unusable
           'alert':1,    #  action must be taken immediately
           'crit':2,     #  critical conditions
           'err':3,      #  error conditions
           'warning':4,  #  warning conditions
           'notice':5,   #  normal but significant condition
           'info':6,     #  informational
           'debug':7 }   #  debug-level messages
g_mask = log_upto('info')
EOF
endfunction

function! s:debug(...)
" [server] sdebug(){ /bin/python ~/vim/vimfiles/plugin/sdebug.py ;}
" [client] :call s:debug('info', 'foo/bar is', foobar, 'and', bar)
if s:vimim_debug < 1 || has('python') < 1
    return
endif
if s:vimim_debug < 2
    call s:netlog_python_init()
    let s:vimim_debug += 1
endif
if s:vimim_debug < 2
    return
endif
:sil!python << EOF
try:
    level = vim.eval("a:1")
    if checkmask(level):
        udpsend(vim.eval("join(a:000)"),"localhost",10007)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: onekey     ==== {{{"]
" =================================================

function! g:vimim_onekey_dump()
    let saved_position = getpos(".")
    let keyboard = get(s:keyboard_list,0)
    let space = repeat(" ", virtcol(".")-len(keyboard)-1)
    for items in s:popupmenu_list
        let line = printf('%s', items.word)
        if has_key(items, "abbr")
            let line = printf('%s', items.abbr)
            if has_key(items, "menu")
                let line = printf('%s %s', items.abbr, items.menu)
            endif
        endif
        put=space.line
    endfor
    call setpos(".", saved_position)
    sil!call g:vimim_stop()
    sil!exe "sil!return '\<Esc>'"
endfunction

function! g:vimim_onekey()
    " (1)<OneKey> in insert mode => start OneKey as the MidasTouch
    " (2)<OneKey> in OneKey mode => stop  OneKey
    " (3)<OneKey> in omni   mode => stop  OneKey and print out menu
    let onekey = ''
    let s:chinese_input_mode = 'onekey'
    sil!call s:vimim_backend_initialization()
    let one_before = getline(".")[col(".")-2]
    if pumvisible() && len(s:popupmenu_list) > 0
        let onekey = '\<C-R>=g:vimim_onekey_dump()\<CR>'
    elseif s:onekey > 0
        let s:seamless_positions = getpos(".")
        sil!call g:vimim_stop()
    elseif s:vimim_onekey_is_tab > 0
        \&& one_before !~ s:valid_key
        \&& !has_key(s:evils,one_before)
        \&& !has_key(s:punctuations,one_before)
        let onekey = '\t'
    else
        sil!call s:vimim_frontend_initialization()
        sil!call s:vimim_onekey_mapping_pumvisible()
        sil!call s:vimim_onekey_mapping_punctuation()
        sil!call s:vimim_start()
        let s:onekey += 1
        let onekey = s:vimim_onekey_action(0)
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_action(space)
    let current_line = getline(".")
    let one_before = current_line[col(".")-2]
    let two_before = current_line[col(".")-3]
    if empty(s:ui.has_dot) && two_before !~# "[0-9a-z']"
        let punctuations = copy(s:punctuations)
        call extend(punctuations, s:evils)
        if has_key(punctuations, one_before)
            for char in keys(punctuations)
                " no transfer for punctuation after punctuation
                if two_before ==# char || two_before =~ '\u'
                    return " "
                endif
            endfor
            " transfer English punctuation to Chinese punctuation
            let bs = punctuations[one_before]
                if one_before == "'" |let bs = <SID>vimim_get_quote(1)
            elseif one_before == '"' |let bs = <SID>vimim_get_quote(2)
            endif
            let onekey = "\<BS>" . bs
            sil!exe 'sil!return "' . onekey . '"'
        endif
    endif
    let onekey = a:space ? " " : ""
    if one_before =~ s:valid_key
        let onekey = g:vimim()
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! <SID>vimim_space()
    " (1) <Space> after English (valid keys) => trigger keycode menu
    " (2) <Space> after English punctuation  => Chinese punctuation
    " (3) <Space> after popup menu           => insert Chinese
    let space = " "
    if pumvisible()
        let space = '\<C-Y>\<C-R>=g:vimim()\<CR>'
        let s:has_pumvisible = 1
        call g:vimim_reset_after_insert()
    elseif s:chinese_input_mode =~ 'static'
        let space = s:vimim_static_action(space)
    elseif s:chinese_input_mode =~ 'onekey'
        let right_arrow = s:vimim_get_right_arrow()
        let space = right_arrow . s:vimim_onekey_action(1)
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

function! s:vimim_get_right_arrow()
    let current_line = getline(".")
    let current_column = col(".")-1
    let start_column = current_column
    let before = current_line[current_column-1]
    let cursor = current_line[current_column]
    let n = 0  " to trigger word under cursor
    if before =~ '\l' && cursor =~ '\l'
        while cursor =~ '\l'
            let current_column += 1
            let cursor = current_line[current_column]
        endwhile
        let n = current_column - start_column
    endif
    let right_arrow = ""
    if n > 0 && n < 72
        let right_arrow = repeat("\<Right>", n)
    endif
    return right_arrow
endfunction

function! g:vimim_menu_to_clip()
    let chinese = s:vimim_popup_word()
    if !empty(chinese)
        if has("gui_running") && has("win32")
            let @+ = chinese
        endif
    endif
    call g:vimim_stop()
    sil!exe "sil!return '\<Esc>'"
endfunction

function! s:vimim_popup_word()
    if pumvisible()
        return ""
    endif
    let column_start = s:start_column_before
    let column_end = col('.') - 1
    let range = column_end - column_start
    let chinese = strpart(getline("."), column_start, range)
    return substitute(chinese,'\w','','g')
endfunction

function! s:vimim_onekey_input(keyboard)
    let keyboard = a:keyboard
    let lines = s:vimim_get_hjkl(keyboard)
    if !empty(lines)
        if s:hjkl_m % 4 > 0  " [game] turn menu 90 degree on hjkl_m
            let &pumheight = 0
            for i in range(s:hjkl_m%4)
                let lines = s:vimim_hjkl_rotation(lines)
            endfor
        endif
        return lines
    endif
    " [dot_by_dot] i.have.a.dream
    let keyboard = s:vimim_dot_by_dot(keyboard)
    " [english] english cannot be ignored
    if keyboard =~ '^\l\+' && empty(s:english_results)
        sil!call s:vimim_onekey_english(keyboard, 0)
    endif
    " [cjk] cjk database works like swiss-army knife
    if !empty(s:cjk_filename)
        if keyboard =~# '^i' " 4corner_shortcut: iypwqwuww => 60212722
            let keyboard = s:vimim_qwertyuiop_1234567890(keyboard[1:])
        endif
        let keyboard = s:vimim_cjk_sentence_match(keyboard)
        let lines = s:vimim_cjk_match(keyboard)
        if keyboard =~ '^\l\d\d\d\d' && len(s:english_results)>0
            call extend(s:english_results, lines)
        endif
    endif
    return lines
endfunction

function! s:vimim_dot_by_dot(keyboard)
    let keyboard = a:keyboard
    if s:ui.has_dot > 0 || keyboard !~ '[^0-9.]'
        return keyboard
    endif
    let partition = match(keyboard, "[.']")
    if partition > -1 && keyboard[-1:] !~ "[.']"
        let keyboard = s:vimim_get_head(keyboard, partition)
    endif
    return keyboard
endfunction

function! s:vimim_get_head(keyboard, partition)
    if a:partition < 0
        return a:keyboard
    endif
    let head = a:keyboard[0 : a:partition-1]
    if len(s:keyboard_list) < 2
        let keyboards = []
        call add(keyboards, head)
        let tail = a:keyboard[a:partition : -1]
        if !empty(tail)
            call add(keyboards, tail)
        endif
        let s:keyboard_list = copy(keyboards)
    endif
    return head
endfunction

function! s:vimim_magic_tail(keyboard)
    let keyboard = a:keyboard
    let magic_tail = keyboard[-1:-1]
    let last_but_one = keyboard[-2:-2]
    if magic_tail =~ "[.']" && last_but_one =~ "[0-9a-z']"
        " <dot> triple play in OneKey:
        "   (1) trailing dot => forced-non-cloud in cloud
        "   (2) trailing dot => forced-cjk-match
        "   (3) as word partition  => match dot by dot
        " <apostrophe> triple play in OneKey:
        "   (1) one   trailing apostrophe => cloud at will
        "   (2) two   trailing apostrophe => cloud for ever
        "   (3) three trailing apostrophe => cloud switch
    else
        return keyboard
    endif
    if magic_tail ==# "."
        let s:cloud_onekey = 0
    elseif magic_tail ==# "'"
        let cloud_ready = s:vimim_set_cloud_if_http_executable(0)
        if cloud_ready > 0
            " trailing apostrophe => forced-cloud
            let s:cloud_onekey = 1
            let last_three = keyboard[-3:-1]
            let keyboard = keyboard[:-2]
            if last_three ==# "'''"
                let keyboard = keyboard[:-3]
                let clouds = split(s:vimim_cloud,',')
                let clouds = clouds[1:-1] + clouds[0:0]
                let s:vimim_cloud = join(clouds,',')
            elseif last_but_one ==# "'"
                let keyboard = keyboard[:-2]
                let s:cloud_onekey = 2
            endif
        endif
    endif
    return keyboard
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: dynamic    ==== {{{"]
" =================================================

function! <SID>VimIMSwitch()
    sil!call s:vimim_backend_initialization()
    if len(s:ui.frontends) < 2
        return <SID>ChineseMode()
    endif
    let s:chinese_input_mode = s:vimim_chinese_input_mode
    let custom_im_list = []
    if s:vimim_toggle_list =~ ","
        let custom_im_list = split(s:vimim_toggle_list, ",")
    else
        if empty(s:vimim_toggle_list)
            let custom_im_list = ["english"]
        endif
        for frontends in s:ui.frontends
            let frontend_im = get(frontends, 1)
            call add(custom_im_list, frontend_im)
        endfor
    endif
    let switch = s:im_toggle % len(custom_im_list)
    let s:im_toggle += 1
    let im = get(custom_im_list, switch)
    let switch = 1
    if im =~ 'english'
        let switch = 0
        let s:frontends = get(s:ui.frontends, 0)
    else
        for frontends in s:ui.frontends
            let frontend_im = get(frontends, 1)
            if frontend_im =~ im
                let s:frontends = frontends
                break
            endif
        endfor
    endif
    return s:vimim_chinese_mode(switch)
endfunction

function! <SID>ChineseMode()
    sil!call s:vimim_backend_initialization()
    if empty(s:ui.frontends)
        return ""
    elseif empty(s:frontends)
        let s:frontends = get(s:ui.frontends, 0)
    endif
    let switch = !empty(&omnifunc) && &omnifunc==#'VimIM' ? 0 : 1
    return s:vimim_chinese_mode(switch)
endfunction

function! s:vimim_chinese_mode(switch)
    let action = ""
    if a:switch < 1
        sil!call g:vimim_stop()
        if mode() == 'n'
            :redraw!
        endif
    else
        let s:chinese_input_mode = s:vimim_chinese_input_mode
        let s:ui.root = get(s:frontends,0)
        let s:ui.im = get(s:frontends,1)
        call s:vimim_set_statusline()
        let action = s:vimim_chinesemode_action()
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

function! <SID>vimim_punctuation_toggle()
    let s:chinese_punctuation = (s:chinese_punctuation+1)%2
    call s:vimim_set_statusline()
    return s:vimim_punctuation_mapping()
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: static     ==== {{{"]
" =================================================

function! s:vimim_chinesemode_action()
    sil!call s:vimim_start()
    sil!call s:vimim_frontend_initialization()
    if s:vimim_chinese_punctuation > -1
        inoremap <expr> <C-^> <SID>vimim_punctuation_toggle()
        call s:vimim_punctuation_mapping()
    endif
    let action = ""
    if s:chinese_input_mode =~ 'dynamic'
        let s:seamless_positions = getpos(".")
        let clouds = split(s:vimim_cloud,',')
        let cloud_in_use = s:ui.root=='cloud' ? match(clouds,s:ui.im) : 0
        let vimim_cloud = get(clouds, cloud_in_use)
        if s:ui.im =~ 'wubi\|erbi' || vimim_cloud =~ 'wubi'
            " dynamic auto trigger for wubi
            for char in s:az_list
                sil!exe 'inoremap <silent> ' . char .
                \ ' <C-R>=g:vimim_wubi_ctrl_e_ctrl_y()<CR>'
                \ . char . '<C-R>=g:vimim()<CR>'
            endfor
        else
            " dynamic alphabet trigger for all
            let not_used_valid_keys = "[0-9.']"
            if s:ui.has_dot == 1
                let not_used_valid_keys = "[0-9]"
            endif
            for char in s:valid_keys
                if char !~# not_used_valid_keys
                    sil!exe 'inoremap <silent> ' . char .
                    \ ' <C-R>=pumvisible() ? "<C-E>" : ""<CR>'
                    \ . char . '<C-R>=g:vimim()<CR>'
                endif
            endfor
        endif
    elseif s:chinese_input_mode =~ 'static'
        let map_list = empty(s:vimim_latex_suite) ? s:Az_list : s:az_list
        for char in map_list
            sil!exe 'inoremap <silent> ' . char .
            \ ' <C-R>=pumvisible() ? "<C-Y>" : ""<CR>'
            \ . char . '<C-R>=g:vimim_reset_after_insert()<CR>'
        endfor
        if pumvisible()
            " <C-\> does nothing on popup menu
        else
            let action = s:vimim_static_action("")
        endif
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

function! s:vimim_static_action(space)
    let space = a:space
    let one_before = getline(".")[col(".")-2]
    if one_before =~# s:valid_key
        let space = g:vimim()
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

function! s:vimim_get_seamless(current_positions)
    if empty(s:seamless_positions) || empty(a:current_positions)
        return -1
    endif
    let seamless_bufnum = s:seamless_positions[0]
    let seamless_lnum = s:seamless_positions[1]
    let seamless_off = s:seamless_positions[3]
    if seamless_bufnum != a:current_positions[0]
    \|| seamless_lnum != a:current_positions[1]
    \|| seamless_off != a:current_positions[3]
        let s:seamless_positions = []
        return -1
    endif
    let seamless_column = s:seamless_positions[2]-1
    let start_column = a:current_positions[2]-1
    let len = start_column - seamless_column
    let start_row = a:current_positions[1]
    let current_line = getline(start_row)
    let snip = strpart(current_line, seamless_column, len)
    if empty(len(snip))
        return -1
    endif
    for char in split(snip, '\zs')
        if char !~# s:valid_key
            return -1
        endif
    endfor
    let s:start_row_before = seamless_lnum
    return seamless_column
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input unicode    ==== {{{"]
" =================================================

function! s:vimim_initialize_encoding()
    let s:encoding = "utf8"
    if &encoding =~ 'chinese\|cp936\|gb2312\|gbk\|euc-cn'
        let s:encoding = "chinese"
    elseif &encoding =~ 'taiwan\|cp950\|big5\|euc-tw'
        let s:encoding = "taiwan"
    endif
    " ------------ ----------------- -------------- -----------
    " vim encoding datafile encoding s:localization performance
    " ------------ ----------------- -------------- -----------
    "   utf-8          utf-8                0          good
    "   chinese        chinese              0          good
    "   utf-8          chinese              1          bad
    "   chinese        utf-8                2          bad
    " ------------ ----------------- -------------- -----------
    let s:localization = 0
    if &encoding == "utf-8"
        if len("datafile_fenc_chinese") > 20110129
            let s:localization = 1
        endif
    else
        let s:localization = 2
    endif
    let s:multibyte = &encoding=="utf-8" ? 3 : 2
endfunction

function! s:vimim_get_char_before(keyboard)
    let current_line = getline(".")
    let start = col(".") -1 - s:multibyte * len(a:keyboard)
    let char_before = current_line[start : start+s:multibyte-1]
    if char_before =~ '\w'
        let char_before = a:keyboard
    endif
    return char_before
endfunction

function! s:vimim_get_unicode_ddddd(keyboard)
    let keyboard = a:keyboard
    if a:keyboard =~ '^u\+$' " get chinese before u: 馬力uu => 39340
        let char_before = s:vimim_get_char_before(keyboard)
        return char2nr(char_before)
    elseif keyboard =~# '^u' && keyboard !~ '[^pqwertyuio]'
        if len(keyboard) == 5 || len(keyboard) == 6
            let keyboard = s:vimim_qwertyuiop_1234567890(keyboard[1:])
            if len(keyboard) == 4              " uoooo  => u9999
                let keyboard = 'u' . keyboard  " uwwwwq => 22221
            endif
        else
            return 0
        endif
    elseif len(keyboard) == 4 && s:vimim_imode_pinyin > 1
    \&& keyboard =~# '^\x\{4}$' && keyboard !~ '^\d\{4}$'
        let keyboard = 'u' . keyboard  " from 4 hex to unicode:  9f9f =>
    endif
    let ddddd = 0
    if keyboard =~# '^u\x\{4}$'        " from   hex to unicode: u808f =>
        let ddddd = str2nr(keyboard[1:],16)
    elseif keyboard =~# '^\d\{5}$'     " from digit to unicode: 32911 =>
        let ddddd = str2nr(keyboard, 10)
    endif
    if ddddd > 0xffff
        let ddddd = 0
    endif
    return ddddd
endfunction

function! s:vimim_cjk_extra_text(chinese)
    let ddddd = char2nr(a:chinese)
    let unicode = ddddd . s:space . printf('u%04x',ddddd)
    if !empty(s:cjk_filename)
        let grep = "^" . a:chinese
        let line = match(s:cjk_lines, grep, 0)
        if line > -1
            let values  = split(get(s:cjk_lines, line))
            let dddd    = s:vimim_digit_4corner>0 ? 2 : 1
            let digit   = s:space . get(values, dddd)
            let pinyin  = s:space . get(values, 3)
            let english = s:space . join(values[4:-2])
            let unicode = unicode . digit . pinyin . english
        endif
    endif
    return unicode
endfunction

function! s:vimim_unicode_to_utf8(xxxx)
    " u808f => 32911 => e8828f
    let ddddd = str2nr(a:xxxx, 16)
    let utf8 = ''
    if ddddd < 128
        let utf8 .= nr2char(ddddd)
    elseif ddddd < 2048
        let utf8 .= nr2char(192+((ddddd-(ddddd%64))/64))
        let utf8 .= nr2char(128+(ddddd%64))
    else
        let utf8 .= nr2char(224+((ddddd-(ddddd%4096))/4096))
        let utf8 .= nr2char(128+(((ddddd%4096)-(ddddd%64))/64))
        let utf8 .= nr2char(128+(ddddd%64))
    endif
    return utf8
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input hjkl       ==== {{{"]
" =================================================

function! s:vimim_cache()
    let results = []
    if s:chinese_input_mode =~ 'onekey'
        if len(s:hjkl_s) > 0
            if len(s:matched_list) > 0 && s:show_me_not > 0
                let results = s:vimim_onekey_menu_format()
            elseif len(s:popupmenu_list) > 0
                let results = s:vimim_onekey_menu_filter()
            endif
        endif
        if s:show_me_not > 0
            if s:hjkl_h % 2 > 0
                for line in s:matched_list
                    let oneline = join(reverse(split(line,'\zs')),'')
                    call add(results, oneline)
                endfor
            endif
        elseif s:hjkl_l > 0 && len(s:matched_list) > &pumheight
            let &pumheight = s:hjkl_l%2<1 ? s:pumheight : 0
        endif
    endif
    if s:pageup_pagedown != 0
    \&& len(s:matched_list) > &pumheight
    \&& s:vimim_custom_label > -1
        return s:vimim_pageup_pagedown()
    endif
    return results
endfunction

function! s:vimim_onekey_menu_format()
    " use 1234567890/qwertyuiop to control popup textwidth
    let lines = copy(s:matched_list)
    let filter = 'substitute(' .'v:val'. ",'^\\s\\+\\|\\s\\+$','','g')"
    call map(lines, filter)
    let lines = split(join(lines),'  ')
    let filter = 'substitute(' .'v:val'. ",' ','','g')"
    call map(lines, filter)
    if s:hjkl_s == 1
        return lines
    endif
    let n = s:hjkl_s * (7-s:multibyte)
    let textwidth = repeat('.', n)
    let results = []
    for line in lines
        let onelines = split(line, textwidth . '\zs')
        call add(onelines, '')
        call extend(results, onelines)
    endfor
    return results
endfunction

function! s:vimim_onekey_menu_filter()
    " use 1234567890/qwertyuiop as digital filter
    let results = s:vimim_cjk_filter_list()
    if empty(results) && !empty(len(s:hjkl_s))
        let number_before = strpart(s:hjkl_s,0,len(s:hjkl_s)-1)
        if len(number_before) > 0
            let s:hjkl_s = number_before
            let results = s:vimim_cjk_filter_list()
        endif
    endif
    return results
endfunction

function! s:vimim_cjk_filter_list()
    let i = 0
    let foods = []
    for items in s:popupmenu_list
        if !empty(s:vimim_cjk_digit_filter(items.word))
            call add(foods, i)
        endif
        let i += 1
    endfor
    if empty(foods)
        return []
    endif
    let results = []
    for i in foods
        let menu = s:popupmenu_list[i].word
        call add(results, menu)
    endfor
    return results
endfunction

function! s:vimim_cjk_digit_filter(chinese)
    " smart digital filter: 马力 7712 4002
    "   (1)   ma<C-6>       马   => filter with   7712
    "   (2) mali<C-6>       马力 => filter with 7 4002
    if empty(len(s:hjkl_s)) || empty(a:chinese)
        return 0
    endif
    let digit_head = ""
    let digit_tail = ""
    let words = split(a:chinese,'\zs')
    for cjk in words
        let grep = "^" . cjk
        let line = match(s:cjk_lines, grep, 0)
        if line < 0
            continue
        else
            let values = split(get(s:cjk_lines, line))
            let dddd = s:vimim_digit_4corner>0 ? 2 : 1
            let digit = get(values, dddd)
            let digit_head .= digit[:0]
            let digit_tail  = digit[1:]
        endif
    endfor
    let number = digit_head . digit_tail
    let pattern = "^" . s:hjkl_s
    if match(number, pattern) < 0
        return 0
    endif
    return a:chinese
endfunction

function! s:vimim_pageup_pagedown()
    let matched_list = s:matched_list
    let length = len(matched_list)
    let one_page = &pumheight
    if s:vimim_custom_label > 0
        let one_page = s:horizontal_display
    endif
    if one_page < 1
        let one_page = 9
    endif
    if length > one_page
        let page = s:pageup_pagedown * one_page
        let partition = page<0 ? length+page : page
        let B = matched_list[partition :]
        let A = matched_list[: partition-1]
        let matched_list = B + A
    endif
    return matched_list
endfunction

function! s:vimim_onekey_mapping_pumvisible()
    for _ in split('hjklmn<>xs', '\zs')
        exe 'inoremap<expr> '._.' <SID>vimim_onekey_hjkl("'._.'")'
    endfor
    let qwerty = s:vimim_onekey_is_tab==2 ? s:qwerty : s:qwerty+range(10)
    for _ in qwerty
        exe 'inoremap<expr> '._.' <SID>vimim_onekey_qwerty("'._.'")'
    endfor
    if empty(s:vimim_latex_suite)
        for _ in s:AZ_list
            exe 'inoremap<expr> '._.' <SID>vimim_onekey_capital("'._.'")'
        endfor
    endif
endfunction

function! <SID>vimim_onekey_hjkl(key)
    let key = a:key
    if pumvisible()
            if a:key == 'j' | let key = '\<Down>'
        elseif a:key == 'k' | let key = '\<Up>'
        elseif a:key =~ "[<>]"
            let key  = '\<C-Y>'.s:punctuations[nr2char(char2nr(a:key)-16)]
        else
            if a:key == 's'
                call g:vimim_reset_after_insert()
            elseif a:key =~ "[hlmnx]"
                for toggle in split('hlmnx','\zs')
                    if toggle == a:key
                        exe 'let s:hjkl_' . toggle . ' += 1'
                        let s:hjkl_n = a:key=='m' ? 0 : s:hjkl_n
                        let s:hjkl_m = a:key=='n' ? 0 : s:hjkl_m
                        break
                    endif
                endfor
            endif
            let key = '\<C-E>\<C-R>=g:vimim()\<CR>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_onekey_qwerty(key)
    let key = a:key
    if pumvisible()
        if key =~ '\l'
            let key = match(s:qwerty, a:key)
        endif
        let s:hjkl_s = s:show_me_not ? key : s:hjkl_s . key
        let key = '\<C-E>\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_onekey_capital(key)
    let key = a:key
    let s:hjkl_h = -1
    let lower = tolower(key)
    let trigger = '\<C-R>=g:vimim()\<CR>'
    if pumvisible()
        let key = '\<C-E>' . lower . trigger
    elseif &ru < 1
        let right_arrow = s:vimim_get_right_arrow()
        let key = lower . right_arrow . trigger
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input cjk        ==== {{{"]
" =================================================

function! s:vimim_scan_cjk_file()
    let s:cjk_lines = []
    let s:cjk_filename = 0
    " http://vimim.googlecode.com/svn/trunk/plugin/vimim.cjk.txt
    let datafile = s:vimim_check_filereadable("vimim.cjk.txt")
    if !empty(datafile)
        let s:cjk_lines = s:vimim_readfile(datafile)
        let s:cjk_filename = datafile
    endif
endfunction

function! s:vimim_cjk_sentence_match(keyboard)
    let keyboard = a:keyboard
    let head = 0
    if s:show_me_not > 0 || len(keyboard) == 1
        let head = keyboard
    elseif keyboard =~ '\d'
        if keyboard =~ '^\d' && keyboard !~ '\D'
            let head = keyboard
            if len(keyboard) > 4
                " output is 6021 for input 6021272260021762
                let head = s:vimim_get_head(keyboard, 4)
            endif
        elseif keyboard =~ '^\l\+\d\+\>'
            let head = keyboard
        elseif keyboard =~ '^\l\+\d\+'
            " output is wo23 for input wo23you40yigemeng
            let partition = match(keyboard, '\d')
            while partition > -1
                let partition += 1
                if keyboard[partition : partition] =~ '\D'
                    break
                endif
            endwhile
            let head = s:vimim_get_head(keyboard, partition)
        endif
    elseif s:ui.im == 'pinyin' || !empty(s:cjk_filename)
        if len(keyboard)%5 < 1 && keyboard !~ "[.']"
        \&& keyboard =~ '^\l' && keyboard[1:4] !~ '[^pqwertyuio]'
            " muuqwxeyqpjeqqq => m7712x3610j3111
            let llll = keyboard[1:4]
            let dddd = s:vimim_qwertyuiop_1234567890(llll)
            if !empty(dddd)
                let ldddd = keyboard[0:0] . dddd
                let keyboard = ldddd . keyboard[5:-1]
                let head = s:vimim_get_head(keyboard, 5)
            endif
        endif
        if empty(head)
            let a_keyboard = keyboard
            if keyboard[-1:] ==# "."
                "  magic trailing dot to use control cjjp: sssss.
                let s:hjkl_m += 1
                let a_keyboard = keyboard[:len(keyboard)-2]
            endif
            let grep = '^' . a_keyboard . '\>'
            let line = match(s:cjk_lines, grep)
            if s:hjkl_m > 0
                let keyboard = s:vimim_toggle_cjjp(a_keyboard)
                if len(s:english_results) > 0
                    let s:english_results = []
                endif
            elseif line < 0 && !empty(s:cjk_filename)
                let keyboard = s:vimim_toggle_pinyin(a_keyboard)
            endif
            let head = s:vimim_dot_by_dot(keyboard)
        endif
    endif
    return head
endfunction

function! s:vimim_qwertyuiop_1234567890(keyboard)
    " output is 7712 for input uuqw
    if a:keyboard =~ '\d'
        return 0
    endif
    let dddd = ""
    for char in split(a:keyboard, '\zs')
        let digit = match(s:qwerty, char)
        if digit < 0
            return 0
        else
            let dddd .= digit
        endif
    endfor
    return dddd
endfunction

function! s:vimim_cjk_match(keyboard)
    if empty(s:cjk_filename)
        return []
    endif
    let keyboard = a:keyboard
    let grep_frequency = '.*' . '\s\d\+$'
    let grep = ""
    if keyboard =~ '\d'
        if keyboard =~# '^\l\l\+[1-5]\>' && empty(len(s:hjkl_s))
            " cjk pinyin with tone: huan2hai2 yi1
            let grep = keyboard . '[a-z ]'
        else
            let digit = ""
            if keyboard =~ '^\d\+' && keyboard !~ '[^0-9.]'
                " cjk free-style digit input: 7 77 771 7712"
                let digit = keyboard
            elseif keyboard =~ '^\l\+\d\+'
                " cjk free-style input/search: ma7 ma77 ma771 ma7712
                let digit = substitute(keyboard,'\a','','g')
            endif
            if !empty(digit)
                let stroke5 = '\d\d\d\d\s'  " 5stroke :: li1234
                let space = '\d\{' . string(4-len(digit)) . '}'
                let space = len(digit)==4 ? "" : space
                let dddd = '\s' . digit . space . '\s'
                let grep = s:vimim_digit_4corner<1 ? dddd.stroke5 : dddd
                let alpha = substitute(keyboard,'\d','','g')
                if !empty(alpha)
                    " search le or yue from le4yue4
                    let grep .= '\(\l\+\d\)\=' . alpha
                elseif len(keyboard) == 1
                    " one-char-list by frequency y72/yue72 l72/le72
                    " search l or y from le4yue4 music happy 426
                    let grep .= grep_frequency
                endif
            endif
            if len(keyboard) < 4 && len(string(digit)) > 0
                let s:hjkl_s = digit
            endif
        endif
    elseif !empty(s:cjk_filename)
        if keyboard == 'u' " 214 standard unicode index
            let grep = '\s\d\d\d\d\s\d\d\d\d\su\s'
        elseif len(keyboard) == 1
            " cjk one-char-list by frequency y72/yue72 l72/le72
            let grep = '[ 0-9]' . keyboard . '\l*\d' . grep_frequency
        elseif keyboard =~ '^\l'
            " cjk multiple-char-list without frequency: huan2hai2
            " support all cases: /huan /hai /yet /huan2 /hai2
            let grep = '[ 0-9]' . keyboard . '[0-9]'
        endif
    else
        return []
    endif
    let results = s:vimim_cjk_grep_results(grep)
    if len(results) > 0
        let results = sort(results, "s:vimim_sort_on_last")
        let filter = "strpart(" . 'v:val' . ", 0, s:multibyte)"
        call map(results, filter)
    endif
    return results
endfunction

function! s:vimim_cjk_grep_results(grep)
    if empty(a:grep) || empty(s:cjk_filename)
        return []
    endif
    let results = []
    let line = match(s:cjk_lines, a:grep)
    while line > -1
        let values = split(get(s:cjk_lines, line))
        let frequency_index = get(values, -1)
        if frequency_index =~ '\l'
            let frequency_index = 9999
        endif
        let chinese_frequency = get(values,0) . ' ' . frequency_index
        call add(results, chinese_frequency)
        let line = match(s:cjk_lines, a:grep, line+1)
    endwhile
    return results
endfunction

function! s:vimim_sort_on_last(line1, line2)
    let line1 = get(split(a:line1),-1) + 1
    let line2 = get(split(a:line2),-1) + 1
    if line1 < line2
        return -1
    elseif line1 > line2
        return 1
    endif
    return 0
endfunction

function! s:vimim_chinese_transfer() range abort
    " (1) "quick and dirty" way to transfer Chinese to Chinese
    " (2) 20% of the effort to solve 80% of the problem using one2one
    sil!call s:vimim_backend_initialization()
    if !empty(s:cjk_filename)
        exe a:firstline.",".a:lastline.'s/./\=s:vimim_1to1(submatch(0))'
    endif
endfunction

function! s:vimim_1to1(char)
    if a:char =~ '[\x00-\xff]'
        return a:char
    endif
    let grep = '^' . a:char
    let line = match(s:cjk_lines, grep, 0)
    if line < 0
        return a:char
    endif
    let values = split(get(s:cjk_lines, line))
    let traditional_chinese = get(split(get(values,0),'\zs'),1)
    if empty(traditional_chinese)
        let traditional_chinese = a:char
    endif
    return traditional_chinese
endfunction

function! <SID>vimim_visual_ctrl6()
    let key = ""
    let onekey = "\<C-R>=g:vimim_onekey()\<CR>"
    let column = virtcol("'<'") - 2
    let space = "\<C-R>=repeat(' '," . column . ")\<CR>"
    let lines = split(getreg('"'), '\n')
    if len(lines) < 2
        let line = get(lines,0)
        let chinese = get(split(line,'\zs'),0)
        if len(substitute(line,'.','.','g')) > 1
            " highlight multiple chinese => show property of each
            let s:seamless_positions = getpos("'<'")
            let ddddd = char2nr(chinese)
            let uddddd = "gvc" . 'u'.ddddd . onekey . 'h'
            let dddd = "gvc" . line . onekey
            let key = ddddd=~'\d\d\d\d\d' ? uddddd : dddd
        else
            " highlight one chinese => get antonym or number loop
            let results = s:vimim_get_imode_chinese(line,0)
            if empty(results)
                let line = -1
                sil!call s:vimim_backend_initialization()
                if !empty(s:cjk_filename)
                    let line = match(s:cjk_lines, "^".chinese)
                endif
                if line < 0
                    let key = "ga"
                else
                    echo get(s:cjk_lines, line)
                endif
            else
                let chinese = get(results,0)
                let key = "gvr" . chinese . "ga"
            endif
        endif
    elseif match(lines,'\d')>-1 && join(lines) !~ '[^0-9[:blank:].]'
        " highlighted digital block => count*average=summary
        let new_positions = getpos(".")
        let new_positions[1] = line("'>'")
        call setpos(".", new_positions)
        let sum = eval(join(lines,'+'))
        let ave = printf("%.2f", 1.0*sum/len(lines))
        let line = ave . "=" . string(sum)
        let line = substitute(line, '[.]0\+', '', 'g')
        let line = string(len(lines)) . '*' . line
        let key = "o^\<C-D>" . space . " " . line . "\<Esc>"
    else
        " highlighted block => display the block in omni window
        let key = "O^\<C-D>" . space . 'vimim.' . onekey
    endif
    sil!call feedkeys(key)
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input english    ==== {{{"]
" =================================================

function! s:vimim_scan_english_datafile()
    let s:english_lines = []
    let s:english_filename = 0
    let datafile = s:vimim_check_filereadable("vimim.txt")
    if !empty(datafile)
        let s:english_lines = s:vimim_readfile(datafile)
        let s:english_filename = datafile
    endif
endfunction

function! s:vimim_check_filereadable(default)
    for dir in [s:vimim_hjkl_directory, s:path]
        let datafile = dir . a:default
        if filereadable(datafile)
            return datafile
        endif
    endfor
    return 0
endfunction

function! s:vimim_onekey_english(keyboard, order)
    let results = []
    if !empty(s:cjk_filename) && a:keyboard !~ '\d'
        " [sql] select english from vimim.cjk.txt
        let grep_english = '\s' . a:keyboard . '\s'
        let results = s:vimim_cjk_grep_results(grep_english)
        if len(results) > 0
            let filter = "strpart(".'v:val'.", 0, s:multibyte)"
            call map(results, filter)
            let s:english_results = copy(results)
        endif
    endif
    if !empty(s:english_filename)
        " [sql] select english from vimim.txt
        let grep_english = '^' . a:keyboard . '\s'
        let matched = match(s:english_lines, grep_english)
        if matched < 0 && len(a:keyboard) > 3
            " support english shortcut: both haag and haagendazs
            let grep_english = '^' . a:keyboard
            let matched = match(s:english_lines, grep_english)
        endif
        if matched > -1
            let line = get(s:english_lines, matched)
            let results = split(line)
            let menu = get(results, 0)
            if menu ==# a:keyboard
                let results = results[1:]
            endif
            let order = empty(a:order) ? len(s:english_results) : 0
            call extend(s:english_results, results, order)
        endif
    endif
endfunction

function! s:vimim_readfile(datafile)
    if !filereadable(a:datafile)
        return []
    endif
    let lines = readfile(a:datafile)
    if s:localization > 0
        let  results = []
        for line in lines
            let line = s:vimim_i18n_read(line)
            call add(results, line)
        endfor
        return results
    endif
    return lines
endfunction

function! s:vimim_i18n_read(line)
    let line = a:line
    if s:localization == 1
        return iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        return iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input pinyin     ==== {{{"]
" =================================================

function! s:vimim_get_pinyin_from_pinyin(keyboard)
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

function! s:vimim_toggle_pinyin(keyboard)
    let keyboard = a:keyboard
    if s:hjkl_n < 1
        return keyboard
    elseif s:hjkl_n % 2 > 0
        " set pin'yin: woyouyigemeng => wo'you'yi'ge'meng
        let keyboard = s:vimim_quanpin_transform(keyboard)
    elseif len(s:keyboard_list) > 0 && get(s:keyboard_list,0) =~ "'"
        " reset pinyin: wo'you'yi'ge'meng => woyouyigemeng
        let keyboard = join(split(join(s:keyboard_list,""),"'"),"")
    endif
    return keyboard
endfunction

function! s:vimim_toggle_cjjp(keyboard)
    let keyboard = a:keyboard
    if s:hjkl_m < 1
        return keyboard
    elseif s:hjkl_m % 2 > 0
        " set cjjp:   wyygm => w'y'y'g'm
        let keyboard = join(split(keyboard,'\zs'),"'")
    elseif len(s:keyboard_list) > 0 && get(s:keyboard_list,0) =~ "'"
        " reset cjjp: w'y'y'g'm => wyygm
        let keyboard = join(split(join(s:keyboard_list,""),"'"),"")
    endif
    return keyboard
endfunction

function! s:vimim_quanpin_transform(pinyin)
    let qptable = s:quanpin_table
    if empty(qptable)
        return ""
    endif
    let item = a:pinyin
    let pinyinstr = ""
    let index = 0
    let lenitem = len(item)
    while index < lenitem
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(qptable, matchstr)
                let tempstr = item[end-1 : end]
                " special case for fanguo, which should be fan'guo
                if tempstr == "gu" || tempstr == "nu" || tempstr == "ni"
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                " follow ibus' rule
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                    \ || (tempstr == "ne" && tempstr3 != "ner")
                    \ || (tempstr4 == "gong" || tempstr3 == "gou")
                    \ || (tempstr4 == "nong" || tempstr3 == "nou")
                    \ || (tempstr == "ga" || tempstr == "na")
                    \ || tempstr2 == "ier"
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . qptable[matchstr]
                let index += i
                break
            elseif i == 1
                let pinyinstr .= "'" . item[index]
                let index += 1
                break
            else
                continue
            endif
        endfor
    endwhile
    if pinyinstr[0] == "'"
        return pinyinstr[1:]
    else
        return pinyinstr
    endif
endfunction

function! s:vimim_create_quanpin_table()
    let pinyin_list = s:vimim_get_pinyin_table()
    let table = {}
    for key in pinyin_list
        if key[0] == "'"
            let table[key[1:]] = key[1:]
        else
            let table[key] = key
        endif
    endfor
    let sheng_mu = "b p m f d t l n g k h j q x zh ch sh r z c s y w"
    for shengmu in split(sheng_mu)
        let table[shengmu] = shengmu
    endfor
    return table
endfunction

function! s:vimim_more_pinyin_candidates(keyboard)
    " [purpose] if not english, make standard layout for popup menu
    " input  =>  mamahuhu
    " output =>  mamahu, mama
    if !empty(s:english_results)
        return []
    endif
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    if empty(a:keyboard) || empty(keyboards)
        return []
    endif
    let candidates = []
    for i in reverse(range(len(keyboards)-1))
        let candidate = join(keyboards[0 : i], "")
        call add(candidates, candidate)
    endfor
    if len(candidates) > 2
        let candidates = candidates[0 : len(candidates)-2]
    endif
    return candidates
endfunction

function! s:vimim_more_pinyin_datafile(keyboard, sentence)
    if s:ui.im !~ 'pinyin'
        return []   " for pinyin with valid keycodes only
    endif
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates)
        return []
    endif
    let results = []
    let lines = s:backend[s:ui.root][s:ui.im].lines
    for candidate in candidates
        let pattern = '^' . candidate . '\>'
        let matched = match(lines, pattern, 0)
        if matched < 0
            continue
        elseif a:sentence > 0
            return [candidate]
        endif
        let oneline = get(lines, matched)
        let matched_list = s:vimim_make_pair_list(oneline)
        call extend(results, matched_list)
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input shuangpin  ==== {{{"]
" =================================================

function! s:vimim_set_shuangpin()
    if empty(s:vimim_shuangpin)
    \|| !empty(s:shuangpin_table)
    \|| s:vimim_cloud =~ 'shuangpin'
        return
    endif
    let s:vimim_imode_pinyin = 0
    let rules = s:vimim_shuangpin_generic()
    let chinese = ""
    let shuangpin = s:vimim_chinese('shuangpin')
    let keycode = "[0-9a-z'.]"
    if s:vimim_shuangpin == 'abc'
        let rules = s:vimim_shuangpin_abc(rules)
        let s:vimim_imode_pinyin = 1
        let chinese = s:vimim_chinese('abc')
        let shuangpin = ""
    elseif s:vimim_shuangpin == 'ms'
        let rules = s:vimim_shuangpin_ms(rules)
        let chinese = s:vimim_chinese('ms')
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin == 'nature'
        let rules = s:vimim_shuangpin_nature(rules)
        let chinese = s:vimim_chinese('nature')
    elseif s:vimim_shuangpin == 'plusplus'
        let rules = s:vimim_shuangpin_plusplus(rules)
        let chinese = s:vimim_chinese('plusplus')
    elseif s:vimim_shuangpin == 'purple'
        let rules = s:vimim_shuangpin_purple(rules)
        let chinese = s:vimim_chinese('purple')
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin == 'flypy'
        let rules = s:vimim_shuangpin_flypy(rules)
        let chinese = s:vimim_chinese('flypy')
    endif
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
    let s:shuangpin_keycode_chinese.chinese = chinese . shuangpin
    let s:shuangpin_keycode_chinese.keycode = keycode
endfunction

function! s:vimim_shuangpin_transform(keyboard)
    let keyboard = a:keyboard
    let size = strlen(keyboard)
    let ptr = 0
    let output = ""
    let bchar = ""    " work-around for sogou
    while ptr < size
        if keyboard[ptr] !~ "[a-z;]"
            " bypass all non-characters, i.e. 0-9 and A-Z are bypassed
            let output .= keyboard[ptr]
            let ptr += 1
        else
            if keyboard[ptr+1] =~ "[a-z;]"
                let sp1 = keyboard[ptr].keyboard[ptr+1]
            else
                let sp1 = keyboard[ptr]
            endif
            if has_key(s:shuangpin_table, sp1)
                " the last odd shuangpin code are output as only shengmu
                let output .= bchar . s:shuangpin_table[sp1]
            else
                " invalid shuangpin code are preserved
                let output .= sp1
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    if output[0] == "'"
        return output[1:]
    else
        return output
    endif
endfunction

"-----------------------------------
function! s:vimim_get_pinyin_table()
"-----------------------------------
" List of all valid pinyin.  Note: Don't change this function!
return [
\"'a", "'ai", "'an", "'ang", "'ao", 'ba', 'bai', 'ban', 'bang', 'bao',
\'bei', 'ben', 'beng', 'bi', 'bian', 'biao', 'bie', 'bin', 'bing', 'bo',
\'bu', 'ca', 'cai', 'can', 'cang', 'cao', 'ce', 'cen', 'ceng', 'cha',
\'chai', 'chan', 'chang', 'chao', 'che', 'chen', 'cheng', 'chi', 'chong',
\'chou', 'chu', 'chua', 'chuai', 'chuan', 'chuang', 'chui', 'chun', 'chuo',
\'ci', 'cong', 'cou', 'cu', 'cuan', 'cui', 'cun', 'cuo', 'da', 'dai',
\'dan', 'dang', 'dao', 'de', 'dei', 'deng', 'di', 'dia', 'dian', 'diao',
\'die', 'ding', 'diu', 'dong', 'dou', 'du', 'duan', 'dui', 'dun', 'duo',
\"'e", "'ei", "'en", "'er", 'fa', 'fan', 'fang', 'fe', 'fei', 'fen',
\'feng', 'fiao', 'fo', 'fou', 'fu', 'ga', 'gai', 'gan', 'gang', 'gao',
\'ge', 'gei', 'gen', 'geng', 'gong', 'gou', 'gu', 'gua', 'guai', 'guan',
\'guang', 'gui', 'gun', 'guo', 'ha', 'hai', 'han', 'hang', 'hao', 'he',
\'hei', 'hen', 'heng', 'hong', 'hou', 'hu', 'hua', 'huai', 'huan', 'huang',
\'hui', 'hun', 'huo', "'i", 'ji', 'jia', 'jian', 'jiang', 'jiao', 'jie',
\'jin', 'jing', 'jiong', 'jiu', 'ju', 'juan', 'jue', 'jun', 'ka', 'kai',
\'kan', 'kang', 'kao', 'ke', 'ken', 'keng', 'kong', 'kou', 'ku', 'kua',
\'kuai', 'kuan', 'kuang', 'kui', 'kun', 'kuo', 'la', 'lai', 'lan', 'lang',
\'lao', 'le', 'lei', 'leng', 'li', 'lia', 'lian', 'liang', 'liao', 'lie',
\'lin', 'ling', 'liu', 'long', 'lou', 'lu', 'luan', 'lue', 'lun', 'luo',
\'lv', 'ma', 'mai', 'man', 'mang', 'mao', 'me', 'mei', 'men', 'meng', 'mi',
\'mian', 'miao', 'mie', 'min', 'ming', 'miu', 'mo', 'mou', 'mu', 'na',
\'nai', 'nan', 'nang', 'nao', 'ne', 'nei', 'nen', 'neng', "'ng", 'ni',
\'nian', 'niang', 'niao', 'nie', 'nin', 'ning', 'niu', 'nong', 'nou', 'nu',
\'nuan', 'nue', 'nuo', 'nv', "'o", "'ou", 'pa', 'pai', 'pan', 'pang',
\'pao', 'pei', 'pen', 'peng', 'pi', 'pian', 'piao', 'pie', 'pin', 'ping',
\'po', 'pou', 'pu', 'qi', 'qia', 'qian', 'qiang', 'qiao', 'qie', 'qin',
\'qing', 'qiong', 'qiu', 'qu', 'quan', 'que', 'qun', 'ran', 'rang', 'rao',
\'re', 'ren', 'reng', 'ri', 'rong', 'rou', 'ru', 'ruan', 'rui', 'run',
\'ruo', 'sa', 'sai', 'san', 'sang', 'sao', 'se', 'sen', 'seng', 'sha',
\'shai', 'shan', 'shang', 'shao', 'she', 'shei', 'shen', 'sheng', 'shi',
\'shou', 'shu', 'shua', 'shuai', 'shuan', 'shuang', 'shui', 'shun', 'shuo',
\'si', 'song', 'sou', 'su', 'suan', 'sui', 'sun', 'suo', 'ta', 'tai',
\'tan', 'tang', 'tao', 'te', 'teng', 'ti', 'tian', 'tiao', 'tie', 'ting',
\'tong', 'tou', 'tu', 'tuan', 'tui', 'tun', 'tuo', "'u", "'v", 'wa', 'wai',
\'wan', 'wang', 'wei', 'wen', 'weng', 'wo', 'wu', 'xi', 'xia', 'xian',
\'xiang', 'xiao', 'xie', 'xin', 'xing', 'xiong', 'xiu', 'xu', 'xuan',
\'xue', 'xun', 'ya', 'yan', 'yang', 'yao', 'ye', 'yi', 'yin', 'ying', 'yo',
\'yong', 'you', 'yu', 'yuan', 'yue', 'yun', 'za', 'zai', 'zan', 'zang',
\'zao', 'ze', 'zei', 'zen', 'zeng', 'zha', 'zhai', 'zhan', 'zhang', 'zhao',
\'zhe', 'zhen', 'zheng', 'zhi', 'zhong', 'zhou', 'zhu', 'zhua', 'zhuai',
\'zhuan', 'zhuang', 'zhui', 'zhun', 'zhuo', 'zi', 'zong', 'zou', 'zu',
\'zuan', 'zui', 'zun', 'zuo']
endfunction

function! s:vimim_create_shuangpin_table(rule)
    let pinyin_list = s:vimim_get_pinyin_table()
    let rules = a:rule
    let sptable = {}
    " generate table for shengmu-yunmu pairs match
    for key in pinyin_list
        if key !~ "['a-z]*"
            continue
        endif
        if key[1] == "h"
            let shengmu = key[:1]
            let yunmu = key[2:]
        else
            let shengmu = key[0]
            let yunmu = key[1:]
        endif
        if has_key(rules[0], shengmu)
            let shuangpin_shengmu = rules[0][shengmu]
        else
            continue
        endif
        if has_key(rules[1], yunmu)
            let shuangpin_yunmu = rules[1][yunmu]
        else
            continue
        endif
        let sp1 = shuangpin_shengmu.shuangpin_yunmu
        if !has_key(sptable, sp1)
            if key[0] == "'"
                let key = key[1:]
            end
            let sptable[sp1] = key
        endif
    endfor
    " the jxqy+v special case handling
    if s:vimim_shuangpin == 'abc'
    \|| s:vimim_shuangpin == 'purple'
    \|| s:vimim_shuangpin == 'nature'
    \|| s:vimim_shuangpin == 'flypy'
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin == 'ms'
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    " the flypy shuangpin special case handling
    if s:vimim_shuangpin == 'flypy'
        let flypy = {"aa" : "a", "oo" : "o", "ee" : "e",
                    \"an" : "an", "ao" : "ao", "ai" : "ai", "ah": "ang",
                    \"os" : "ong","ou" : "ou",
                    \"en" : "en", "er" : "er", "ei" : "ei", "eg": "eng" }
        call extend(sptable, flypy)
    endif
    " the nature shuangpin special case handling
    if s:vimim_shuangpin == 'nature'
        let nature = {"aa" : "a", "oo" : "o", "ee" : "e" }
        call extend(sptable, nature)
    endif
    " generate table for shengmu-only match
    for [key, value] in items(rules[0])
        if key[0] == "'"
            let sptable[value] = ""
        else
            let sptable[value] = key
        end
    endfor
    return sptable
endfunction

function! s:vimim_shuangpin_generic()
    " generate the default value of shuangpin table
    let shengmu_list = {}
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g",
                \"k", "h", "j", "q", "x", "r", "z", "c", "s", "y", "w"]
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in ["a", "o", "e", "i", "u", "v"]
        let yunmu_list[yunmu] = yunmu
    endfor
    let s:shuangpin_rule = [shengmu_list, yunmu_list]
    return s:shuangpin_rule
endfunction

function! s:vimim_shuangpin_abc(rule)
    " goal: vtpc => shuang pin => double pinyin
    call extend(a:rule[0],{ "zh" : "a", "ch" : "e", "sh" : "v" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "q", "eng": "g", "ng" : "g",
        \"ia" : "d", "iu" : "r", "ie" : "x", "in" : "c", "ing": "y",
        \"iao": "z", "ian": "w", "iang": "t", "iong" : "s",
        \"un" : "n", "ua" : "d", "uo" : "o", "ue" : "m", "ui" : "m",
        \"uai": "c", "uan": "p", "uang": "t" } )
    return a:rule
endfunction

function! s:vimim_shuangpin_ms(rule)
    " goal: vi=>zhi ii=>chi ui=>shi keng=>keneng
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": ";",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" ,
        \"v" : "y"} )
    return a:rule
endfunction

function! s:vimim_shuangpin_nature(rule)
    " goal: 'woui' => wo shi => i am
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": "y",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" } )
    return a:rule
endfunction

function! s:vimim_shuangpin_plusplus(rule)
    call extend(a:rule[0],{ "zh" : "v", "ch" : "u", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "f", "ao" : "d", "ai" : "s", "ang": "g",
        \"ong": "y", "ou" : "p",
        \"en" : "r", "er" : "q", "ei" : "w", "eng": "t", "ng" : "t",
        \"ia" : "b", "iu" : "n", "ie" : "m", "in" : "l", "ing": "q",
        \"iao": "k", "ian": "j", "iang" : "h", "iong" : "y",
        \"un" : "z", "ua" : "b", "uo" : "o", "ue" : "x", "ui" : "v",
        \"uai": "x", "uan": "c", "uang" : "h" } )
    return a:rule
endfunction

function! s:vimim_shuangpin_purple(rule)
    call extend(a:rule[0],{ "zh" : "u", "ch" : "a", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "r", "ao" : "q", "ai" : "p", "ang": "s",
        \"ong": "h", "ou" : "z",
        \"en" : "w", "er" : "j", "ei" : "k", "eng": "t", "ng" : "t",
        \"ia" : "x", "iu" : "j", "ie" : "d", "in" : "y", "ing": ";",
        \"iao": "b", "ian": "f", "iang" : "g", "iong" : "h",
        \"un" : "m", "ua" : "x", "uo" : "o", "ue" : "n", "ui" : "n",
        \"uai": "y", "uan": "l", "uang" : "g"} )
    return a:rule
endfunction

function! s:vimim_shuangpin_flypy(rule)
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "c", "ai" : "d", "ang": "h",
        \"ong": "s", "ou" : "z",
        \"en" : "f", "er" : "r", "ei" : "w", "eng": "g", "ng" : "g",
        \"ia" : "x", "iu" : "q", "ie" : "p", "in" : "b", "ing": "k",
        \"iao": "n", "ian": "m", "iang" : "l", "iong" : "s",
        \"un" : "y", "ua" : "x", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "k", "uan": "r", "uang" : "l" } )
    return a:rule
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend file     ==== {{{"]
" =================================================

function! s:vimim_scan_backend_embedded()
    let im = "pinyin"
    if isdirectory(s:path.im)
        let s:vimim_data_directory = s:path . im
    endif
    if isdirectory(s:vimim_data_directory)
        if filereadable(s:vimim_data_directory.im)
            return s:vimim_set_directory(im, s:vimim_data_directory)
        endif
    endif
    let db = "http://vimim.googlecode.com/svn/trunk/plugin/vimim.pinyin.db"
    let datafile = s:vimim_check_filereadable(get(split(db,"/"),-1))
    if !empty(datafile) && has("python")
        :python import vim, bsddb
        :python db = bsddb.btopen(vim.eval('datafile'),'r')
        :call s:vimim_database_init()
    else
        let datafile = s:vimim_data_file
    endif
    if !empty(datafile) && filereadable(datafile)
        let im = get(split(datafile,"[.]"),1)
        return s:vimim_set_datafile(im, datafile)
    endif
    for im in s:all_vimim_input_methods
        let datafile = s:path . "vimim." . im . ".txt"
        if filereadable(datafile)
            call s:vimim_set_datafile(im, datafile)
        else
            let im = im . "." . &encoding
            let datafile = s:path . "vimim." . im . ".txt"
            if filereadable(datafile)
                call s:vimim_set_datafile(im, data_file)
                let s:localization = 0
            endif
        endif
    endfor
endfunction

function! s:vimim_set_datafile(im, datafile)
    let datafile = a:datafile
    let im = s:vimim_get_valid_im_name(a:im)
    if empty(im) || isdirectory(datafile)
        return
    endif
    let s:vimim_data_file = datafile
    let s:ui.root = "datafile"
    let s:ui.im = im
    let frontends = [s:ui.root, s:ui.im]
    call insert(s:ui.frontends, frontends)
    let s:backend.datafile[im] = s:vimim_one_backend_hash()
    let s:backend.datafile[im].root = "datafile"
    let s:backend.datafile[im].im = im
    let s:backend.datafile[im].name = datafile
    let s:backend.datafile[im].keycode = s:im_keycode[im]
    let s:backend.datafile[im].chinese = s:vimim_chinese(im)
    if datafile =~ ".txt" && empty(s:backend.datafile[im].lines)
        let s:backend.datafile[im].lines = s:vimim_readfile(datafile)
    endif
    call s:vimim_set_special_im_property()
endfunction

function! s:vimim_sentence_datafile(keyboard)
    let keyboard = a:keyboard
    let lines = s:backend[s:ui.root][s:ui.im].lines
    if empty(lines) || !empty(s:english_results)
        return ""
    endif
    let pattern = '^' . keyboard . '\s'
    let matched = match(lines, pattern)
    if matched > -1
        return keyboard
    endif
    let candidates = s:vimim_more_pinyin_datafile(keyboard,1)
    if !empty(candidates)
        return get(candidates,0)
    endif
    " wo'you'yige'meng works in this algorithm
    let max = len(keyboard)
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let pattern = '^' . head . '\s'
        let matched = match(lines, pattern)
        if matched < 0
            continue
        else
            break
        endif
    endwhile
    if matched < 0
        return ""
    endif
    return keyboard[0 : max-1]
endfunction

function! s:vimim_get_from_datafile(keyboard, search)
    let lines = s:backend[s:ui.root][s:ui.im].lines
    let pattern = '^' . a:keyboard . '\s'
    let matched = match(lines, pattern)
    if matched < 0
        return []
    endif
    let results = []
    " http://code.google.com/p/vimim/issues/detail?id=121
    if s:vimim_more_candidates > 0
        for i in range(s:vimim_more_candidates)
            let matched += i
            let oneline = get(lines, matched)
            let extras = s:vimim_make_pair_list(oneline)
            call extend(results, extras)
        endfor
    else
        let oneline = get(lines, matched)
        let onelines = split(oneline)
        let results = split(oneline)[1:]
        if a:search < 1 && len(onelines) > 0 && len(onelines) < 20
            let extras = s:vimim_more_pinyin_datafile(a:keyboard,0)
            if len(extras) > 0
                let results = s:vimim_make_pair_list(oneline)
                call extend(results, extras)
            endif
        endif
    endif
    return results
endfunction

function! s:vimim_get_from_database(keyboard, search)
    function! s:vimim_get_chinese_from_bsd(stone)
        :python gold = getgold(vim.eval('a:stone'))
        :python vim.command("return '%s'" % gold)
    endfunction
    let oneline = s:vimim_get_chinese_from_bsd(a:keyboard)
    let results = s:vimim_make_pair_list(oneline)
    if empty(a:search) && len(results) > 0 && len(results) < 20
        let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
        if len(candidates) > 1
            for candidate in candidates
                let oneline = s:vimim_get_chinese_from_bsd(candidate)
                let matched_list = s:vimim_make_pair_list(oneline)
                if !empty(matched_list)
                    call extend(results, matched_list)
                endif
                if len(results) > 20*2
                    break
                endif
            endfor
        endif
    endif
    return results
endfunction

function! s:vimim_make_pair_list(oneline)
    if empty(a:oneline)
        return []
    endif
    let oneline_list = split(a:oneline)
    let menu = remove(oneline_list, 0)
    if empty(menu) || menu =~ '\W'
        return []
    endif
    if !empty(s:english_results)
        return oneline_list
    endif
    let results = []
    for chinese in oneline_list
        call add(results, menu .' '. chinese)
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend dir      ==== {{{"]
" =================================================

function! s:vimim_set_directory(im, dir)
    let im = s:vimim_get_valid_im_name(a:im)
    if empty(im) || empty(a:dir) || !isdirectory(a:dir)
        return
    endif
    let s:ui.root = "directory"
    let s:ui.im = im
    let frontends = [s:ui.root, s:ui.im]
    call insert(s:ui.frontends, frontends)
    if empty(s:backend.directory)
        let s:backend.directory[im] = s:vimim_one_backend_hash()
        let s:backend.directory[im].root = "directory"
        let s:backend.directory[im].name = a:dir
        let s:backend.directory[im].im = im
        let s:backend.directory[im].keycode = s:im_keycode[im]
        let s:backend.directory[im].chinese = s:vimim_chinese(im)
    endif
    call s:vimim_set_special_im_property()
endfunction

function! s:vimim_more_pinyin_directory(keyboard, dir)
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates)
        return []
    endif
    let results = []
    for candidate in candidates
        let matches = []
        let filename = a:dir . candidate
        if filereadable(filename)
            let matches = s:vimim_readfile(filename)
        elseif s:chinese_input_mode =~ 'onekey'
            let matches = s:vimim_cjk_match(candidate)[0:20]
        endif
        if !empty(matches)
            call map(matches, 'candidate ." ". v:val')
            call extend(results, matches)
        endif
    endfor
    return results
endfunction

function! s:vimim_sentence_directory(keyboard)
    let keyboard = a:keyboard
    let filename = s:vimim_data_directory . keyboard
    if filereadable(filename)
        return keyboard
    elseif !empty(s:english_results)
        return ""
    endif
    let candidates = s:vimim_more_pinyin_datafile(keyboard,1)
    if !empty(candidates)
        return get(candidates,0)
    endif
    let max = len(keyboard)
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let filename = s:vimim_data_directory . head
        " workaround: filereadable("/filename.") returns true
        if filereadable(filename)
            if head[-1:-1] != "."
                break
            endif
        else
            continue
        endif
    endwhile
    if filereadable(filename)
        return keyboard[0 : max-1]
    endif
    return ""
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend cloud    ==== {{{"]
" =================================================

function! s:vimim_initialize_cloud()
    let cloud_default = 'baidu,sogou,qq,google'
    let cloud_defaults = split(cloud_default,',')
    let s:cloud_default = get(cloud_defaults,0)
    let s:cloud_defaults = copy(cloud_defaults)
    let s:cloud_keys = {}
    let s:cloud_cache = {}
    for cloud in cloud_defaults
        let s:cloud_keys[cloud] = 0
        let s:cloud_cache[cloud] = {}
    endfor
    if empty(s:vimim_cloud)
        let s:vimim_cloud = cloud_default
    else
        let clouds = split(s:vimim_cloud,',')
        for cloud in clouds
            let cloud = get(split(cloud,'[.]'),0)
            call remove(cloud_defaults, match(cloud_defaults,cloud))
        endfor
        let clouds += cloud_defaults
        let s:vimim_cloud = join(clouds,',')
        let default = get(split(get(clouds,0),'[.]'),0)
        if match(cloud_default, default) > -1
            let s:cloud_default = default
        endif
    endif
    let s:mycloud = 0
    let s:http_executable = 0
    let s:cloud_onekey = s:vimim_cloud=~'onekey' ? 2 : 0
endfunction

function! s:vimim_set_cloud(im)
    let im = a:im
    let cloud = s:vimim_set_cloud_if_http_executable(im)
    if empty(cloud)
        let s:backend.cloud = {}
        return
    endif
    if  empty(s:vimim_imode_pinyin)
        let s:vimim_imode_pinyin = 1
    endif
    let s:mycloud = 0
    let s:ui.root = 'cloud'
    let s:ui.im = im
    let frontends = [s:ui.root, s:ui.im]
    call add(s:ui.frontends, frontends)
    let clouds = split(s:vimim_cloud,',')
    for cloud in clouds
        let cloud = get(split(cloud,'[.]'),0)
        if cloud == im
            continue
        endif
        call s:vimim_set_cloud_if_http_executable(cloud)
        let frontends = [s:ui.root, cloud]
        call add(s:ui.frontends, frontends)
    endfor
endfunction

function! s:vimim_scan_backend_cloud()
    let set_cloud = 0
    if empty(s:backend.datafile) && empty(s:backend.directory)
        let set_cloud = 1
    endif
    if s:vimim_toggle_list =~ 'cloud'
        let set_cloud = 1
    endif
    if set_cloud > 0
        call s:vimim_set_cloud(s:cloud_default)
    endif
endfunction

function! s:vimim_set_cloud_if_http_executable(im)
    if empty(s:http_executable)
        if empty(s:vimim_check_http_executable())
            return 0
        endif
    endif
    let im = a:im
    if empty(im)
        let im = s:cloud_default
    endif
    let s:backend.cloud[im] = s:vimim_one_backend_hash()
    let s:backend.cloud[im].root = 'cloud'
    let s:backend.cloud[im].im = im
    let s:backend.cloud[im].keycode = s:im_keycode[im]
    let s:backend.cloud[im].chinese = s:vimim_chinese(im)
    let s:backend.cloud[im].name = s:vimim_chinese(im)
    return 1
endfunction

function! s:vimim_check_http_executable()
    if s:vimim_cloud < 0 && len(s:vimim_mycloud) < 2
        return 0
    endif
    " step 1 of 4: try to use dynamic python: +python/dyn +python3/dyn
    if has('python')
        let s:http_executable = 'Python2 Interface to Vim'
    endif
    if has('python3') && &relativenumber > 0
        let s:http_executable = 'Python3 Interface to Vim'
    endif
    " step 2 of 4: try to find libvimim for mycloud
    let libvimim = s:vimim_get_libvimim()
    if !empty(libvimim) && filereadable(libvimim)
        " in win32, strip the .dll suffix
        if has("win32") && libvimim[-4:] ==? ".dll"
            let libvimim = libvimim[:-5]
        endif
        let ret = libcall(libvimim, "do_geturl", "__isvalid")
        if ret ==# "True"
            let s:http_executable = libvimim
        endif
    endif
    " step 3 of 4: try to find wget
    if empty(s:http_executable)
        let wget = 'wget'
        let wget_exe = s:path . 'wget.exe'
        if filereadable(wget_exe)
            let wget = wget_exe
        endif
        if executable(wget)
            let wget_option = " -qO - --timeout 20 -t 10 "
            let s:http_executable = wget . wget_option
        endif
    endif
    " step 4 of 4: try to find curl if wget not available
    if empty(s:http_executable) && executable('curl')
        let s:http_executable = "curl -s "
    endif
    return s:http_executable
endfunction

function! s:vimim_do_cloud_or_not(keyboard)
    if s:vimim_cloud < 0 || a:keyboard =~ "[^a-z]"
        return 0
    endif
    if s:cloud_onekey > 0
        return 1
    endif
    if s:chinese_input_mode=~'onekey' && !empty(s:cjk_filename)
        return 0
    endif
    if s:ui.root == 'cloud'
        return 1
    endif
    return 0
endfunction

function! s:vimim_get_cloud(keyboard, cloud)
    let keyboard = a:keyboard
    let cloud = a:cloud
    if keyboard !~ s:valid_key
    \|| empty(cloud)
    \|| match(s:vimim_cloud,cloud) < 0
        return []
    endif
    let results = []
    if has_key(s:cloud_cache[cloud], keyboard)
        return s:cloud_cache[cloud][keyboard]
    endif
    let get_cloud = "s:vimim_get_cloud_" . cloud . "(keyboard)"
    try
        let results = eval(get_cloud)
    catch
        call s:debug('alert', 'get_cloud::' . cloud . '::', v:exception)
    endtry
    if (len(results)) > 1
        let s:cloud_cache[cloud][keyboard] = results
    endif
    return results
endfunction

function! s:vimim_get_from_http(input, cloud)
    let input = a:input
    if empty(input)
        return ""
    endif
    if empty(s:http_executable)
        if empty(s:vimim_check_http_executable())
            return ""
        endif
    endif
    let output = ""
    try
        if s:http_executable =~ 'Python3'
            let output = s:vimim_get_from_python3(input, a:cloud)
        elseif s:http_executable =~ 'Python2'
            let output = s:vimim_get_from_python2(input, a:cloud)
        elseif s:http_executable =~ 'libvimim'
            let output = libcall(s:http_executable, "do_geturl", input)
        else
            let output = system(s:http_executable . '"'.input.'"')
        endif
    catch
        call s:debug('alert', 'http_cloud', output ." ". v:exception)
    endtry
    return output
endfunction

function! s:vimim_get_cloud_sogou(keyboard)
    " http://web.pinyin.sogou.com/api/py?key=32&query=mxj
    if empty(s:cloud_keys.sogou)
        let key_sogou = 'http://web.pinyin.sogou.com/web_ime/patch.php'
        let output = s:vimim_get_from_http(key_sogou, 'sogou')
        if empty(output) || output =~ '502 bad gateway'
            return []
        endif
        let s:cloud_keys.sogou = get(split(output,'"'),1)
    endif
    let input  = 'http://web.pinyin.sogou.com/api/py'
    let input .= '?key=' . s:cloud_keys.sogou
    let input .= '&query=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'sogou')
    if empty(output) || output =~ '502 bad gateway'
        return []
    endif
    let first  = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first > 0 && second > 0
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if s:localization > 0
        " support gb and big5 in addition to utf8
        let output = s:vimim_i18n_read(output)
    endif
    let matched_list = []
    for item in split(output, '\t+')
        let item_list = split(item, s:colon)
        if len(item_list) > 1
            let chinese = get(item_list,0)
            let english = strpart(a:keyboard, 0, get(item_list,1))
            let new_item = english . " " . chinese
            call add(matched_list, new_item)
        endif
    endfor
    return matched_list
endfunction

function! s:vimim_get_cloud_qq(keyboard)
    " http://ime.qq.com/fcgi-bin/getword?key=32&q=mxj
    let url = 'http://ime.qq.com/fcgi-bin/'
    if empty(s:cloud_keys.qq)
        let key_qq = url . 'getkey'
        let output = s:vimim_get_from_http(key_qq, 'qq')
        if empty(output) || output =~ '502 bad gateway'
            return []
        endif
        let s:cloud_keys.qq = get(split(output,'"'),3)
    endif
    if len(s:cloud_keys.qq) != 32
        return []
    endif
    let input  = url
    let clouds = split(s:vimim_cloud,',')
    let vimim_cloud = get(clouds, match(clouds,'qq'))
    if vimim_cloud =~ 'wubi'
        let input .= 'gwb'
    else
        let input .= 'getword'
    endif
    let input .= '?key=' . s:cloud_keys.qq
    if vimim_cloud =~ 'fanti'
        let input .= '&jf=1'
    endif
    let md = 0
    if vimim_cloud =~ 'mixture'
        let md = 3
    endif
    if vimim_cloud =~ 'shuangpin'
        let md = 2
        let st = 0
            if vimim_cloud =~ 'abc'      | let st = 1
        elseif vimim_cloud =~ 'ms'       | let st = 2
        elseif vimim_cloud =~ 'plusplus' | let st = 3
        elseif vimim_cloud =~ 'purple'   | let st = 4
        elseif vimim_cloud =~ 'flypy'    | let st = 5
        elseif vimim_cloud =~ 'nature'   | let st = 6 | endif
        if st > 0
            let input .= '&st=' . st
        endif
    endif
    if md > 0
        let input .= '&md=' . md
    endif
    if vimim_cloud =~ 'fuzzy'
        let input .= '&mh=1'
    endif
    let input .= '&q=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'qq')
    if empty(output) || output =~ '502 bad gateway'
        return []
    endif
    if s:localization > 0
        " qq => {"q":"fuck","rs":["\xe5\xa6\x87"],
        let output = s:vimim_i18n_read(output)
    endif
    let key = 'rs'
    let matched_list = []
    let output_hash = eval(output)
    if type(output_hash) == type({}) && has_key(output_hash, key)
        let matched_list = output_hash[key]
    endif
    if vimim_cloud !~ 'wubi' && vimim_cloud !~ 'shuangpin'
        let matched_list = s:vimim_cloud_pinyin(a:keyboard, matched_list)
    endif
    return matched_list
endfunction

function! s:vimim_get_cloud_google(keyboard)
    " http://google.com/transliterate?tl_app=3&tlqt=1&num=20&text=mxj
    let input  = 'http://www.google.com/transliterate/chinese'
    let input .= '?langpair=en|zh'
    let input .= '&num=20'
    let input .= '&tl_app=3'
    let input .= '&tlqt=1'
    let input .= '&text=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'google')
    let output = join(split(output))
    let matched_list = []
    if s:localization > 0
        " google => '[{"ew":"fuck","hws":["\u5987\u4EA7\u79D1",]},]'
        if s:http_executable =~ 'Python2'
            let output = s:vimim_i18n_read(output)
        else
            let unicodes = split(get(split(output),8),",")
            for item in unicodes
                let utf8 = ""
                for xxxx in split(item,"\u")
                    let utf8 .= s:vimim_unicode_to_utf8(xxxx)
                endfor
                let output = s:vimim_i18n_read(utf8)
                call add(matched_list, output)
            endfor
            return matched_list
        endif
    endif
    let key = 'hws'
    let output_hash = get(eval(output),0)
    if type(output_hash) == type({}) && has_key(output_hash, key)
        let matched_list = output_hash[key]
    endif
    return s:vimim_cloud_pinyin(a:keyboard, matched_list)
endfunction

function! s:vimim_cloud_pinyin(keyboard, matched_list)
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    let matched_list = []
    for chinese in a:matched_list
        let len_chinese = len(split(chinese,'\zs'))
        let english = join(keyboards[len_chinese :], "")
        let yin_yang = chinese
        if !empty(english)
            let yin_yang .= english
        endif
        call add(matched_list, yin_yang)
    endfor
    return matched_list
endfunction

function! s:vimim_get_cloud_baidu(keyboard)
    " http://olime.baidu.com/py?rn=0&pn=20&py=mxj
    let input  = 'http://olime.baidu.com/py'
    let input .= '?rn=0'
    let input .= '&pn=20'
    let input .= '&py=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'baidu')
    let output_list = []
    if exists("g:baidu") && type(g:baidu) == type([])
        let output_list = get(g:baidu,0)
    endif
    if empty(output_list)
        if empty(output) || output =~ '502 bad gateway'
            return []
        elseif empty(s:localization)
            " ['[[["\xc3\xb0\xcf\xd5\xbc\xd2",3]
            let output = iconv(output, "gbk", "utf-8")
        endif
        let output_list = get(eval(output),0)
    endif
    if type(output_list) != type([])
        return []
    endif
    let matched_list = []
    for item_list in output_list
        let chinese = get(item_list,0)
        if chinese =~ '\w'
            continue
        endif
        let english = strpart(a:keyboard, get(item_list,1))
        let yin_yang = chinese . english
        call add(matched_list, yin_yang)
    endfor
    return matched_list
endfunction

function! s:vimim_get_cloud_all(keyboard)
    let results = []
    for cloud in ['google', 'baidu', 'sogou', 'qq']
        let start = localtime()
        let outputs = s:vimim_get_cloud(a:keyboard, cloud)
        call add(results, s:space)
        let title  = a:keyboard . s:space
        let title .= s:vimim_chinese(cloud)
        let title .= s:vimim_chinese('cloud')
        let title .= s:vimim_chinese('input')
        let duration = localtime() - start
        if duration > 0
            let title .= s:space . string(duration)
        endif
        call add(results, title)
        if len(outputs) > 1+1+1+1
            let outputs = &number<1 ? outputs[0:8] : outputs
            let filter = "substitute(" . 'v:val' . ",'[a-z ]','','g')"
            call add(results, join(map(outputs,filter)))
        endif
    endfor
    call s:debug('info', 'cloud_results=', results)
    let s:show_me_not = 1
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend mycloud  ==== {{{"]
" =================================================

function! s:vimim_scan_backend_mycloud()
    let s:mycloud_arg  = 0
    let s:mycloud_func = 0
    let s:mycloud_host = 0
    let s:mycloud_mode = 0
    let s:mycloud_port = 0
    let im = 'mycloud'
    let s:backend.cloud[im] = s:vimim_one_backend_hash()
    let mycloud = s:vimim_check_mycloud_availability()
    if empty(mycloud)
        let s:mycloud = 0
        let s:backend.cloud = {}
    else
        let root = 'cloud'
        let s:backend.cloud[im].root = root
        let s:backend.cloud[im].im = im
        let s:backend.cloud[im].name    = s:vimim_chinese(im)
        let s:backend.cloud[im].chinese = s:vimim_chinese(im)
        let s:ui.im = im
        let s:ui.root = root
        let s:ui.frontends = [[s:ui.root, s:ui.im]]
        let s:vimim_shuangpin = 0
        let s:vimim_cloud = -1
        let s:mycloud = mycloud
    endif
endfunction

function! s:vimim_check_mycloud_availability()
    let cloud = 0
    if empty(s:vimim_mycloud)
        let cloud = s:vimim_check_mycloud_plugin_libcall()
    else
        let cloud = s:vimim_check_mycloud_plugin_url()
    endif
    if empty(cloud)
        return 0
    endif
    let ret = s:vimim_access_mycloud(cloud, "__getkeychars")
    let keycode = split(ret, "\t")[0]
    if empty(keycode)
        return 0
    endif
    let ret = s:vimim_access_mycloud(cloud, "__getname")
    let directory = split(ret, "\t")[0]
    let s:backend.cloud.mycloud.directory = directory
    let s:backend.cloud.mycloud.keycode = keycode
    return cloud
endfunction

function! s:vimim_access_mycloud(cloud, cmd)
    " use the same function to access mycloud by libcall() or system()
    let ret = ""
    if s:mycloud_mode == "libcall"
        let arg = s:mycloud_arg
        if empty(arg)
            let ret = libcall(a:cloud, s:mycloud_func, a:cmd)
        else
            let ret = libcall(a:cloud, s:mycloud_func, arg." ".a:cmd)
        endif
    elseif s:mycloud_mode == "python"
        let host = s:mycloud_host
        let port = s:mycloud_port
        let ret = s:vimim_mycloud_python_client(a:cmd, host, port)
    elseif s:mycloud_mode == "system"
        let ret = system(a:cloud." ".shellescape(a:cmd))
    elseif s:mycloud_mode == "www"
        let input = s:vimim_rot13(a:cmd)
        let http = s:http_executable
        if http =~ 'libvimim'
            let ret = libcall(http, "do_geturl", a:cloud.input)
        elseif len(http) > 0
            let ret = system(http . shellescape(a:cloud.input))
        endif
        if len(ret) > 0
            let output = s:vimim_rot13(ret)
            let ret = s:vimim_url_xx_to_chinese(output)
        endif
    endif
    return ret
endfunction

function! s:vimim_rot13(keyboard)
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    return tr(a:keyboard, a.z, z.a)
endfunction

function! s:vimim_get_libvimim()
    let cloud = ""
    if has("win32") || has("win32unix")
        let cloud = "libvimim.dll"
    elseif has("unix")
        let cloud = "libvimim.so"
    else
        return ""
    endif
    let cloud = s:path . cloud
    if filereadable(cloud)
        return cloud
    endif
    return ""
endfunction

function! s:vimim_check_mycloud_plugin_libcall()
    " we do plug-n-play for libcall(), not for system()
    let cloud = s:vimim_get_libvimim()
    if !empty(cloud)
        let s:mycloud_mode = "libcall"
        let s:mycloud_arg = ""
        let s:mycloud_func = 'do_getlocal'
        if filereadable(cloud)
            if has("win32")
                " we don't need to strip ".dll" for "win32unix".
                let cloud = cloud[:-5]
            endif
            try
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                call s:debug('alert', 'libcall_mycloud2=',v:exception)
            endtry
        endif
    endif
    " libcall check failed, we now check system()
    if has("gui_win32")
        return 0
    endif
    " on linux, we do plug-n-play
    let cloud = s:path . "mycloud/mycloud"
    if !executable(cloud)
        if !executable("python")
            return 0
        endif
        let cloud = "python " . cloud
    endif
    " in POSIX system, we can use system() for mycloud
    let s:mycloud_mode = "system"
    let ret = s:vimim_access_mycloud(cloud, "__isvalid")
    if split(ret, "\t")[0] == "True"
        return cloud
    endif
    return 0
endfunction

function! s:vimim_check_mycloud_plugin_url()
    " we do set-and-play on all systems
    let part = split(s:vimim_mycloud, ':')
    let lenpart = len(part)
    if lenpart <= 1
        call s:debug('info', "invalid_cloud_plugin_url")
    elseif part[0] ==# 'app'
        if !has("gui_win32")
            " strip the first root if contains ":"
            if lenpart == 3
                if part[1][0] == '/'
                    let cloud = part[1][1:] . ':' .  part[2]
                else
                    let cloud = part[1] . ':' . part[2]
                endif
            elseif lenpart == 2
                let cloud = part[1]
            endif
            " in POSIX system, we can use system() for mycloud
            if executable(split(cloud, " ")[0])
                let s:mycloud_mode = "system"
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            endif
        endif
    elseif part[0] ==# 'py'
        if has("python")
            " python 2 support code here
            if lenpart > 2
                let s:mycloud_host = part[1]
                let s:mycloud_port = part[2]
            elseif lenpart > 1
                let s:mycloud_host = part[1]
                let s:mycloud_port = 10007
            else
                let s:mycloud_host = "localhost"
                let s:mycloud_port = 10007
            endif
            try
                call s:vimim_mycloud_python_init()
                let s:mycloud_mode = "python"
                let cloud = part[1]
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return "python"
                endif
            catch
                call s:debug('alert', 'python_mycloud::', v:exception)
            endtry
        endif
    elseif part[0] ==# "dll"
        if len(part[1]) == 1
            let base = 1
        else
            let base = 0
        endif
        " provide function name
        if lenpart >= base+4
            let s:mycloud_func = part[base+3]
        else
            let s:mycloud_func = 'do_getlocal'
        endif
        " provide argument
        if lenpart >= base+3
            let s:mycloud_arg = part[base+2]
        else
            let s:mycloud_arg = ""
        endif
        " provide the dll
        if base == 1
            let cloud = part[1] . ':' . part[2]
        else
            let cloud = part[1]
        endif
        if filereadable(cloud)
            let s:mycloud_mode = "libcall"
            " strip off the .dll suffix, only required for win32
            if has("win32") && cloud[-4:] ==? ".dll"
                let cloud = cloud[:-5]
            endif
            try
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                call s:debug('alert', 'libcall_mycloud::', v:exception)
            endtry
        endif
    elseif part[0] ==# "http" || part[0] ==# "https"
        if empty(s:vimim_check_http_executable())
            return 0
        endif
        if !empty(s:http_executable)
            let s:mycloud_mode = "www"
            let ret = s:vimim_access_mycloud(s:vimim_mycloud,"__isvalid")
            if split(ret, "\t")[0] == "True"
                return s:vimim_mycloud
            endif
        endif
    else
        call s:debug('alert', "invalid_cloud_plugin_url")
    endif
    return 0
endfunction

function! s:vimim_get_mycloud_plugin(keyboard)
    if empty(s:mycloud)
        return []
    endif
    let output = 0
    try
        let output = s:vimim_access_mycloud(s:mycloud, a:keyboard)
    catch
        call s:debug('alert', 'mycloud::',v:exception)
    endtry
    if empty(output)
        return []
    endif
    let results = []
    for item in split(output, '\n')
        let item_list = split(item, '\t')
        let chinese = get(item_list,0)
        if s:localization > 0
            let chinese = s:vimim_i18n_read(chinese)
        endif
        if empty(chinese) || get(item_list,1,-1)<0
            " bypass the debug line which have -1
            continue
        endif
        let extra_text = get(item_list,2)
        let english = a:keyboard[get(item_list,1):]
        let new_item = extra_text . " " . chinese . english
        call add(results, new_item)
    endfor
    return results
endfunction

function! s:vimim_url_xx_to_chinese(xx)
    " %E9%A6%AC => \xE9\xA6\xAC => 馬 u99AC
    let output = a:xx
    if s:http_executable =~ 'libvimim'
        let output = libcall(s:http_executable, "do_unquote", a:xx)
    else
        let pat = '%\(\x\x\)'
        let sub = '\=eval(''"\x''.submatch(1).''"'')'
        let output = substitute(a:xx, pat, sub, 'g')
    endif
    return output
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

function! s:vimim_initialize_i_setting()
    let s:cpo         = &cpo
    let s:omnifunc    = &omnifunc
    let s:completeopt = &completeopt
    let s:laststatus  = &laststatus
    let s:statusline  = &statusline
    let s:lazyredraw  = &lazyredraw
    let s:showmatch   = &showmatch
    let s:smartcase   = &smartcase
    let s:ruler       = &ruler
endfunction

function! s:vimim_setting_on()
    set imdisable
    set iminsert=0
    set completeopt=menuone
    set omnifunc=VimIM
    set nolazyredraw
    set noshowmatch
    set noruler
    if &pumheight < 1 || &pumheight > 10
        let &pumheight = len(s:abcd)
        if !empty(s:cjk_filename)
            let &pumheight -= 1
        endif
        let s:pumheight = &pumheight
    endif
    if s:vimim_custom_label > 0
        let &pumheight = s:horizontal_display
    endif
    highlight  default CursorIM guifg=NONE guibg=green gui=NONE
    highlight! link Cursor CursorIM
endfunction

function! s:vimim_restore_setting()
    let &cpo         = s:cpo
    let &omnifunc    = s:omnifunc
    let &completeopt = s:completeopt
    let &laststatus  = s:laststatus
    let &statusline  = s:statusline
    let &lazyredraw  = s:lazyredraw
    let &showmatch   = s:showmatch
    let &smartcase   = s:smartcase
    let &pumheight   = s:pumheight_saved
    let &ruler       = s:ruler
    highlight! link Cursor NONE
endfunction

function! s:vimim_start()
    sil!call s:vimim_plugin_conflict_fix_on()
    sil!call s:vimim_setting_on()
    sil!call s:vimim_super_reset()
    sil!call s:vimim_label_on()
    inoremap <expr> <BS>    <SID>vimim_backspace()
    inoremap <expr> <Space> <SID>vimim_space()
    inoremap <expr> <Esc>   <SID>vimim_esc()
    inoremap <expr> <CR>    <SID>vimim_enter()
endfunction

function! g:vimim_stop()
    sil!call s:vimim_restore_setting()
    sil!call s:vimim_super_reset()
    sil!call s:vimim_imap_off()
    sil!call s:vimim_plugin_conflict_fix_off()
    sil!call s:vimim_imap_for_chinesemode()
    sil!call s:vimim_imap_for_onekey()
endfunction

function! s:vimim_super_reset()
    sil!call s:vimim_reset_before_anything()
    sil!call s:vimim_reset_before_omni()
    sil!call g:vimim_reset_after_insert()
endfunction

function! s:vimim_reset_before_anything()
    let s:cloud_onekey = s:cloud_onekey>1 ? 2 : 0
    let s:onekey = 0
    let s:has_pumvisible = 0
    let s:popupmenu_list = []
    let s:keyboard_list  = []
endfunction

function! s:vimim_reset_before_omni()
    let s:smart_enter = 0
    let s:show_me_not = 0
    let s:english_results = []
endfunction

function! g:vimim_reset_after_insert()
    let s:hjkl_h = 0
    let s:hjkl_l = 0
    let s:hjkl_m = 0
    let s:hjkl_n = 0
    let s:hjkl_x = 0
    let s:hjkl_s = ""
    let s:matched_list = []
    let s:pageup_pagedown = 0
    if s:vimim_custom_label < 1
        let &pumheight = s:pumheight
    endif
    return ""
endfunction

function! g:vimim()
    let key = ""
    let s:keyboard_list = []
    let one_before = getline(".")[col(".")-2]
    if one_before =~ s:valid_key
        let key = '\<C-X>\<C-O>\<C-R>=g:vimim_menu_select()\<CR>'
    else
        let s:has_pumvisible = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_menu_select()
    let key = pumvisible() ? '\<C-P>\<Down>' : ""
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_imap_off()
    let recycles = range(0,9) + s:valid_keys
    if s:chinese_input_mode!~'dynamic' && empty(s:vimim_latex_suite)
        let recycles += s:AZ_list
    endif
    let recycles += keys(s:evils) + keys(s:punctuations)
    let recycles += ['<Esc>','<CR>','<BS>','<Space>']
    for _ in recycles
        if len(maparg(_, 'i')) > 0
            sil!exe 'iunmap '. _
        endif
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core engine      ==== {{{"]
" =================================================

function! VimIM(start, keyboard)
if a:start
    let current_positions = getpos(".")
    let start_row = current_positions[1]
    let start_column = current_positions[2]-1
    let current_line = getline(start_row)
    let one_before = current_line[start_column-1]
    let seamless_column = s:vimim_get_seamless(current_positions)
    if seamless_column >= 0
        let len = current_positions[2]-1 - seamless_column
        let keyboard = strpart(current_line, seamless_column, len)
        call s:vimim_set_keyboard_list(seamless_column, keyboard)
        return seamless_column
    endif
    let last_seen_nonsense_column  = copy(start_column)
    let last_seen_backslash_column = copy(start_column)
    let nonsense = s:vimim_imode_pinyin>1 ? "[a-f0-9.']" : "[0-9.']"
    let all_digit = 1
    while start_column > 0
        if one_before =~# s:valid_key
            let start_column -= 1
            if one_before !~# nonsense && s:ui.has_dot < 1
                let last_seen_nonsense_column = start_column
                if all_digit > 0
                    let all_digit = 0
                endif
            endif
        elseif one_before=='\' && s:vimim_backslash_close_pinyin>0
            " do nothing for pinyin with leading backslash
            return last_seen_backslash_column
        else
            break
        endif
        let one_before = current_line[start_column-1]
    endwhile
    if all_digit < 1 && current_line[start_column]=~'\d'
        let start_column = last_seen_nonsense_column
    endif
    let s:start_row_before = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let keyboard = strpart(current_line, start_column, len)
    call s:vimim_set_keyboard_list(start_column, keyboard)
    return start_column
else
    " [cache] less is more
    let results = s:vimim_cache()
    if !empty(results)
        return s:vimim_popupmenu_list(results)
    endif
    " [initialization] early start, half done
    let keyboard = a:keyboard
    call s:vimim_reset_before_omni()
    " [validation] user keyboard input validation
    if empty(str2nr(keyboard))
        " keyboard input is alphabet only
    elseif len(s:keyboard_list) > 0
        let keyboard = get(s:keyboard_list,0)
    endif
    if empty(keyboard) || keyboard !~# s:valid_key
        return []
    endif
    " [onekey] play with nothing but OneKey
    if s:chinese_input_mode =~ 'onekey'
       " [clouds] all clouds for any input: fuck''''
        if keyboard[-4:] ==# "''''"
            let results = s:vimim_get_cloud_all(keyboard[:-5])
            return s:vimim_popupmenu_list(results)
        endif
        let results = s:vimim_onekey_input(keyboard)
        if empty(len(results))
            if s:ui.root == 'cloud' && !empty(s:english_results)
                return s:vimim_popupmenu_list(s:english_results)
            endif
        elseif empty(s:english_results)
            return s:vimim_popupmenu_list(results)
        endif
    endif
    " [mycloud] get chunmeng from mycloud local or www
    if !empty(s:mycloud)
        let results = s:vimim_get_mycloud_plugin(keyboard)
        if !empty(len(results))
            return s:vimim_popupmenu_list(results)
        endif
    endif
    " [cloud] magic trailing apostrophe to control cloud
    if s:chinese_input_mode =~ 'onekey' && keyboard !~ '\d'
        let keyboard = s:vimim_magic_tail(keyboard)
    endif
    " [shuangpin] support 6 major shuangpin
    if !empty(s:vimim_shuangpin) && s:has_pumvisible < 1
        let keyboard = s:vimim_shuangpin_transform(keyboard)
        let s:keyboard_list = [keyboard]
    endif
    " [cloud] to make dream come true for multiple clouds
    let cloud = 0
    let clouds = split(s:vimim_cloud,',')
    let cloud_in_use = s:ui.root=='cloud' ? match(clouds,s:ui.im) : 0
    let vimim_cloud = get(clouds, cloud_in_use)
    if s:vimim_do_cloud_or_not(keyboard) > 0
        let cloud = get(split(vimim_cloud,'[.]'),0)
        if !empty(s:frontends) && get(s:frontends,0) =~ 'cloud'
            let cloud = get(s:frontends,1)
        endif
        let results = s:vimim_get_cloud(keyboard, cloud)
        if !empty(len(results))
            let s:keyboard_list = [keyboard]
            return s:vimim_popupmenu_list(results)
        endif
    endif
    " [wubi] support auto insert for every 4 input
    if s:ui.im =~ 'wubi\|erbi' || vimim_cloud =~ 'wubi'
        let keyboard = s:vimim_wubi_auto_input_on_the_4th(keyboard)
    endif
    " [backend] plug-n-play embedded backend engine
    let results = s:vimim_embedded_backend_engine(keyboard,0)
    if !empty(s:english_results)
        let s:keyboard_list = [keyboard]
        call extend(results, s:english_results, 0)
    endif
    if !empty(results) && get(results,0) !~ 'None\|0'
        return s:vimim_popupmenu_list(results)
    endif
    " [just_do_it] last try on both cjk and cloud before giving up
    if !empty(s:cjk_filename) && s:chinese_input_mode=~'onekey'
        let keyboard_head = s:vimim_cjk_sentence_match(keyboard.".")
        if !empty(keyboard_head)
            let results = s:vimim_cjk_match(keyboard_head)
        endif
    elseif keyboard !~# '\L'
        let results = s:vimim_get_cloud(keyboard, cloud)
    endif
    if !empty(len(results))
        return s:vimim_popupmenu_list(results)
    elseif s:chinese_input_mode =~ 'onekey'
        sil!call s:vimim_super_reset()
    endif
return []
endif
endfunction

function! s:vimim_popupmenu_list(matched_list)
    let lines = a:matched_list
    if empty(lines) || type(lines) != type([])
        return []
    endif
    let s:matched_list = a:matched_list
    let tail = 0
    let label = 1
    let extra_text = ""
    let popupmenu_list = []
    let popupmenu_list_one_row = []
    let first_in_list = get(lines,0)
    let keyboard = join(s:keyboard_list,"")
    let &pumheight = s:show_me_not ? 0 : &pumheight
    if s:hjkl_n % 2 > 0
        if s:show_me_not > 0
            call reverse(lines)
            let label = len(lines)
        elseif s:ui.im == 'pinyin' || s:ui.root == 'cloud'
            let keyboard = join(split(join(s:keyboard_list,""),"'"),"")
        endif
    endif
    let menu = get(s:keyboard_list,0)
    for chinese in lines
        let complete_items = {}
        if first_in_list =~ '\s' && s:show_me_not < 1
            let pairs = split(chinese)
            if len(pairs) > 1
                let chinese = get(pairs, 1)
                let menu = get(pairs, 0)
            endif
            if s:vimim_custom_menu > 0
                let extra_text = menu
            endif
        endif
        if s:hjkl_x>0 && s:hjkl_x%2>0 && !empty(s:cjk_filename)
            let simplified_traditional = ""
            for char in split(chinese, '\zs')
                let simplified_traditional .= s:vimim_1to1(char)
            endfor
            let chinese = simplified_traditional
        endif
        if s:hjkl_h>0 && s:hjkl_h%2>0 && len(chinese)%s:multibyte<1
            let extra_text = menu
            if empty(s:english_results)
                let extra_text = s:vimim_cjk_extra_text(chinese)
            endif
        endif
        if empty(s:mycloud)
            if !empty(keyboard) && s:show_me_not < 1
                let keyboard_head_length = len(menu)
                if empty(s:ui.has_dot) && keyboard =~ "['.]"
                    " for vimim classic demo: i.have.a.dream
                    let keyboard_head_length += 1
                endif
                let tail = strpart(keyboard, keyboard_head_length)
                let chinese .= tail
            endif
        elseif s:horizontal_display < 1 && s:show_me_not < 1
            let extra_text = get(split(menu,"_"),0)
        endif
        if s:vimim_custom_label > 0
            let abbr = label . "." . chinese
            call add(popupmenu_list_one_row, abbr)
        endif
        let hjkl_h = 0
        if len(lines)>1 || get(s:keyboard_list,0)=~'^u\d\d\d\d\d$'
            let hjkl_h = 1
        endif
        if hjkl_h > 0 && s:vimim_custom_label > -1
            let labeling = label . " "
            if s:show_me_not <= -7
                let labeling = ""
            elseif s:vimim_custom_label < 1
                let labeling = s:vimim_get_labeling(label)
            endif
            if s:hjkl_n % 2 > 0 && s:show_me_not > 0
                let label -= 1
            else
                let label += 1
            endif
            let complete_items["abbr"] = labeling . chinese
        endif
        let complete_items["dup"] = 1
        let complete_items["menu"] = extra_text
        let complete_items["word"] = empty(chinese) ? s:space : chinese
        call add(popupmenu_list, complete_items)
    endfor
    if s:chinese_input_mode =~ 'onekey'
        let s:popupmenu_list = popupmenu_list
    endif
    let height = s:horizontal_display
    if s:show_me_not < 1 && len(popupmenu_list) > 1 && height > 0
        let one_list = popupmenu_list_one_row
        if len(one_list) > height
            let one_list = popupmenu_list_one_row[0 : height-1]
        endif
        let cursor_gps = 1.0 * (virtcol(".") % &columns) / &columns
        let onerow_gps = 1.0 * len(join(one_list)) / &columns
        if cursor_gps < 0.72 && onerow_gps < 0.92
            let start = 1
            let display = 0
            let line1 = line("w$") - line(".")
            let line2 = line("w$") - line("w0")
            if line1 < height+2 && line2 > &lines-height- 2
                let start = 0
                let display = height-1
            endif
            if display < len(popupmenu_list)
                let popupmenu_list[display].abbr = join(one_list)
            endif
            let empty_lines = range(start, start+height-2)
            for i in empty_lines
                if i < len(popupmenu_list)
                    let popupmenu_list[i].abbr = s:space
                endif
            endfor
        endif
    endif
    return popupmenu_list
endfunction

function! s:vimim_embedded_backend_engine(keyboard, search)
    let keyboard = a:keyboard
    let im = s:ui.im
    let root = s:ui.root
    if empty(im) || empty(root) || empty(keyboard)
    \|| im =~ 'cloud' || s:show_me_not > 0 || keyboard !~# s:valid_key
        return []
    endif
    if im == 'pinyin'
        let keyboard = s:vimim_toggle_pinyin(keyboard)
        if s:ui.has_dot == 2 && keyboard !~ "[']"
            let keyboard = s:vimim_quanpin_transform(keyboard)
        endif
    endif
    let results = []
    let keyboard2 = 0
    if root =~# "directory"
        let dir = s:backend[root][im].name
        let keyboard2 = s:vimim_sentence_directory(keyboard)
        let results = s:vimim_readfile(dir . keyboard2)
        if keyboard ==# keyboard2 && a:search < 1
        \&& len(results) > 0 && len(results) < 20
            let extras = s:vimim_more_pinyin_directory(keyboard, dir)
            if len(extras) > 0 && len(results) > 0
                call map(results, 'keyboard ." ". v:val')
                call extend(results, extras)
            endif
        endif
    elseif root =~# "datafile"
        if s:vimim_data_file =~ ".db"
            :python keyboard = vim.eval('keyboard')
            :python partition = int(vim.eval('s:hjkl_h'))
            :python keyboard2 = getstone(keyboard, partition)
            :python vim.command("let keyboard2 = '%s'" % keyboard2)
            let results = s:vimim_get_from_database(keyboard2, a:search)
        else
            let keyboard2 = s:vimim_sentence_datafile(keyboard)
            let results = s:vimim_get_from_datafile(keyboard2, a:search)
        endif
    endif
    if len(s:keyboard_list) < 2
        if empty(keyboard2)
            let s:keyboard_list = [keyboard]
        elseif len(keyboard2) < len(keyboard)
            let tail = strpart(keyboard,len(keyboard2))
            let s:keyboard_list = [keyboard2, tail]
            if empty(s:hjkl_h) && s:vimim_data_file =~ ".db"
                let s:hjkl_h += len(tail)
            endif
        endif
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

function! s:vimim_imap_for_chinesemode()
    if s:vimim_onekey_is_tab < 2
         noremap<silent>  <C-Bslash>  :call <SID>ChineseMode()<CR>
            imap<silent>  <C-Bslash>  <Plug>VimIM
        inoremap<silent><expr> <C-X><C-Bslash> <SID>VimIMSwitch()
        if s:vimim_ctrl_h_to_toggle == 1
            imap <C-H> <C-Bslash>
        elseif s:vimim_ctrl_h_to_toggle == 2
            inoremap<silent><expr> <C-H> <SID>VimIMSwitch()
        endif
    endif
    if s:vimim_ctrl_space_to_toggle == 1
        if has("gui_running")
             map <C-Space> <C-Bslash>
            imap <C-Space> <C-Bslash>
        elseif has("win32unix")
             map <C-@> <C-Bslash>
            imap <C-@> <C-Bslash>
        endif
    elseif s:vimim_ctrl_space_to_toggle == 2
        if has("gui_running")
            inoremap<silent><expr> <C-Space> <SID>VimIMSwitch()
        elseif has("win32unix")
            inoremap<silent><expr> <C-@> <SID>VimIMSwitch()
        endif
    endif
endfunction

function! s:vimim_imap_for_onekey()
    if s:vimim_onekey_is_tab < 2
            imap<silent> <C-^> <Plug>VimimOneKey
        xnoremap<silent> <C-^> y:call <SID>vimim_visual_ctrl6()<CR>
    endif
    if s:vimim_onekey_is_tab > 0
            imap<silent> <Tab> <Plug>VimimOneKey
        xnoremap<silent> <Tab> y:call <SID>vimim_visual_ctrl6()<CR>
    endif
    if s:vimim_search_next > 0
        noremap <silent> n :call g:vimim_search_next()<CR>n
    endif
    :com! -range=% VimIM <line1>,<line2>call s:vimim_chinese_transfer()
    :com! -range=% ViMiM <line1>,<line2>call s:vimim_chinese_rotation()
endfunction

function! s:vimim_initialize_plugin()
    if !hasmapto("VimimOneKey")
        inoremap<unique><expr> <Plug>VimimOneKey g:vimim_onekey()
    endif
    if !hasmapto("VimIM") && s:vimim_onekey_is_tab < 2
        inoremap<unique><expr> <Plug>VimIM  <SID>ChineseMode()
    endif
endfunction

sil!call s:vimim_initialize_local()
sil!call s:vimim_initialize_global()
sil!call s:vimim_initialize_cloud()
sil!call s:vimim_initialize_plugin()
sil!call s:vimim_imap_for_chinesemode()
sil!call s:vimim_imap_for_onekey()
" ======================================= }}}
