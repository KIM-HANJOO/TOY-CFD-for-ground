# 6-6-6-3D-Heat-transfer-model


simple **6-6-6 size 3D ground Heat-transfer model**

with unsteady 2D heat-transfer room model

<plotting of the code>


![plott](https://user-images.githubusercontent.com/82522118/117552847-dcb7b580-b088-11eb-83df-c9eabe4a2556.png)
Coded for 'Building Energy Modeling and Analysis' course of 'School of Civil, Environmenta and Architectural Engineering, Korea .UNIV'

***


### read.me


0. MATLAB is required
1.  download and place the files in **the same folder**
2.  run **'set_up.mat'**
3.  run **'Heat_transfer_3Dground_simulation.mat'**
4.  run **'Heat_transfer_3Dground_plotter.mat'**


> 'room_input(2)' contains the informations of the room we are modeling  
> 'TMY3' contains the weather data of a whole year (from 1/1 to 12/31)



### Concept 


1.  mesh 12m * 12m * 12m sized ground with 2m interval
2.  cubes will be made by meshing the ground (6 * 6 * 6)
3.  center of the cubes represents 'nodes'
4.  every nodes(= cubes) exchange heat with 6 face-to-face attached nodes (= cubes)
