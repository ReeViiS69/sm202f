/* Generated by firmware/Makefile */
    .section .rodata
    .p2align 3
_fw_tsp_himax_hx83102d_a20e_al_fw_bin:
    .incbin "firmware/tsp_himax/hx83102d_a20e_al.fw"
_fw_end:
   .section .rodata.str,"aMS",@progbits,1
    .p2align 3
_fw_tsp_himax_hx83102d_a20e_al_fw_name:
    .string "tsp_himax/hx83102d_a20e_al.fw"
    .section .builtin_fw,"a",@progbits
    .p2align 3
    .quad _fw_tsp_himax_hx83102d_a20e_al_fw_name
    .quad _fw_tsp_himax_hx83102d_a20e_al_fw_bin
    .quad _fw_end - _fw_tsp_himax_hx83102d_a20e_al_fw_bin
