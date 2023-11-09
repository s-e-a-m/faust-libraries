import("stdfaust.lib");

complex = ffunction(int complex(any), "complex.h","");

process = complex(os.osc(1000));
