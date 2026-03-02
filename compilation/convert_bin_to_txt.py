# -*- coding: utf-8 -*-
"""

@author: Omar
"""


def convert_instr_bin_to_txt(filename):
    bin_file = open("./bin/" + filename, "rb")
    bin_data = bin_file.read()
    bin_file.close()
    
    output_filename = filename[:filename.find(".")] + ".txt"
    
    txt_file = open("./bin/" + output_filename, "w")
    
    n_bytes = len(bin_data)
    
    if n_bytes % 4 != 0 :
        print(filename + " : invalid length.")
        return
    
    n_words = n_bytes // 4
    
    txt_file.write(f'SIZE_BYTES = {n_bytes}\n')
    txt_file.write(f'SIZE_WORDS = {n_words}\n\n')
    txt_file.write("Content: \n")
    
    for i in range(n_words):
        word = "x\""
        for j in range(4):
            word += "{:02x}".format(bin_data[4*i+3-j])
        word += "\""
        if(i < n_words-1):
            word += ","
        word += "\n"
        txt_file.write(word)
    
    print(output_filename + " generated.")
    
    
    
    
def convert_data_rom_bin_to_txt(filename):
    bin_file = open("./bin/" + filename, "rb")
    bin_data = bin_file.read()
    bin_file.close()
    
    output_filename = filename[:filename.find(".")] + ".txt"
    
    txt_file = open("./bin/" + output_filename, "w")
    
    n_bytes = len(bin_data)
    
    if n_bytes % 4 != 0 :
        print(filename + " : invalid length.")
        return
    
    n_words = n_bytes // 4
    
    
    txt_file.write(f'SIZE_BYTES = {n_bytes}\n')
    txt_file.write(f'SIZE_WORDS = {n_words}\n\n')
    txt_file.write("Content: \n")
    
    for i in range(n_words):
        w = "("
        for j in range(4):
            w += "x\""
            w += "{:02x}".format(bin_data[4*i + 3-j])
            w += "\""
            if(j < 3):
                w += ", "
            else:
                w += ")"
                
        if(i < n_words-1):
            w += ","
        w += "\n"
        
        txt_file.write(w)
        
        
        
    print(output_filename + " generated.")
    
    return bin_data
    

convert_instr_bin_to_txt("instr.bin")
convert_data_rom_bin_to_txt("rodata.bin")
