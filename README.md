# 6-6-6-3D-Heat-transfer-model


simple **6-6-6 size 3D ground Heat-transfer model**

with unsteady 2D heat-transfer room model

<plotting of the code>


![2_1_12 (3)](https://user-images.githubusercontent.com/82522118/117623559-e9cec480-b1ae-11eb-9b61-bc2c6f3df2a2.jpg)
_Coded for 'Building Energy Modeling and Analysis' course of 'Civil, Environmental and Architectural Engineering, Korea .UNIV'_

***


### read.me


0. MATLAB is required
1.  download and place the files in **the same folder**
2.  run **'set_up.mat'**
3.  run **'Heat_transfer_3Dground_simulation.mat'**
4.  run **'Heat_transfer_3Dground_plotter.mat'**


> 'room_input(2)' contains the informations of the room we are modeling  
> 'TMY3' contains the weather data of a whole year (from January 1st to December 31st)



### Concept 


1.  mesh 12m * 12m * 12m sized ground with 2m interval
2.  cubes will be made by meshing (6 * 6 * 6)
3.  center of the cubes represents 'nodes'
4.  every nodes(= cubes) exchange heat with 6 face-to-face attached nodes (= cubes)



### Plus

In simulating this unsteady heat-transfer model, most problems appeared were related to **'Thermal mass'** and **'boundary conditions'**.  Ground's thermal mass is too big that if T0 of the nodes were set far from their normal temperature range, the simulation should need more than a year to finish warmup(which is quite out of our weather data range). Also, meshing wasn't set finely enough, number of heat transfer times from boundary condition nodes to non-boundary nodes were not enough. In addition to this, because the thermal mass of the ground nodes are too big, the effect of boundary condition nodes began worse.

Therefore, more specific settings for **warmup** and **boundary conditions** are required for the huge-thermal mass nodes. In warming up season, **thermal mass needs to be adjusted lower enough** for ground nodes to easily find the normal temperature range, and **temperature of the boundary condition nodes should be updated every time interval** with other reasonable simulation results.

These problems were reflected to the codes, but since the accuracy isn't high enough and the assumptions are way too simple, more updates for the codes are needed.



+) 4-4-4 model with same method

![4-4-4](https://user-images.githubusercontent.com/82522118/117623624-fb17d100-b1ae-11eb-8bf2-840cedb62a71.jpg)
