#  FastCorrection_verilog
## What is FastCorrection_verilog
In the non-coaxial image fusion optical system, when the uncooled infrared detector and the low-illumination CMOS detector image the same infinity scene, due to the nature of the detector and the mechanical error of the system assembly, Image is not exactly the same,  there is translation, rotation and scaling relationship between the two images, in addition, the image itself is also a distortion problem. Therefore, the system needs to be registered before image fusion, so that the infrared and low light images can be completely matched. According to the offset between the infrared image and the glimmer image, the program can correct the infrared image to a position that can match the glimmer image.


## Project structure and introduction
vivado generate dual-port RAM core, called BRAM, raw format image read BRAM. Generate ROM core (v2.0 after the use of external SRAM model, model GS8644Z36E), the look-up table read into ROM. Crc module read the ROM data in turn, according to the data, Crc module remove the corresponding pixel gray value in the BRAM, and so on, and finally complete the correction.

Correction_tb.v : testbeach Module
Correction.v : Global Module
Crc.v : Correction Module

## How to use FastCorrection_verilog
step 1:
Use Matlab procedures to generate a look-up table
step 2:
Create a vivado project，Generate the required IP core。
step 3:
simulate Correction_tb.v
