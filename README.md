# 6-6-6-3D-Heat-transfer-model


simple **6-6-6 size 3D ground Heat-transfer model**

with unsteady 2D heat-transfer room model

<plotting of the code>


![미리보기용](https://user-images.githubusercontent.com/82522118/117624296-bb9db480-b1af-11eb-8973-7e2ba3383f19.png)
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
3.  center of every cubes underground represents 'nodes'
4.  every nodes(= cubes) exchange heat with 6 face-to-face attached nodes (= cubes)


### Key Assumptions

1. The ground is made up of homogeneous soil and has the same property at any point, regardless of depth or location.

2. Ignore the shade effect by the building and surroundings. Temperatures are the same at any point on the surface.

3. Assume that underground temperature begins constant from the depth of 12 meters

4. All cubes (=nodes) produced by meshing exchange heat solely through conduction, with six other cubes (=nodes) adjacent to the face.

### issues

The main purpose of heat transfer model is to predict indoor air temp under changing outdoor air temp. ODE starts to calculate from one boundary condition node to another, and the nodes that are at the path of the ODE will get the temperature difference through time as a result. So the result of simulation unconditionally depends on the temp of boundary conditions. As the number of boundary condition nodes is quite large, and thouse 116 boundary condtion nodes' temperature are fixed, result of the simulation should be sadly inaccurate. As it is hard to expect that there will be the data of cubes(newly defined by me), we have to simulate the boundary conditions' thermal behavior. What I suggest is to delete building part in the 3D heat transfer model, and simulate with only soil and surface nodes. With this simulation and fixed boundary condition temperature, we can get the temp difference through time and depth of the vertical nodes at the center of 12m * 12m * 12m space(in this case, (3, 3, z) nodes) as a result. Than re-input the temp data to the boundary condition nodes, depending on depth and updating through time intervals and re-simulate. The result of the vertical nodes at the cent, will converge to certain data. This data can be the temperature data of boundary conditionnodes.

in 216 nodes additionally added, 116 nodes are boundary conditions. (boundary condition nodes / all nodes) are approximately near half. this ratio is pretty high, and because 

### Plus

In simulating this unsteady heat-transfer model, most problems appeared were related to **'Thermal mass'** and **'boundary conditions'**.  Ground's thermal mass is too big that if T0 of the nodes were set far from their normal temperature range, the simulation should need more than a year to finish warmup(which is quite out of our weather data range). Also, meshing wasn't set finely enough, number of heat transfer times from boundary condition nodes to non-boundary nodes were not enough. In addition to this, because the thermal mass of the ground nodes are too big, the effect of boundary condition nodes began worse.

Therefore, more specific settings for **warmup** and **boundary conditions** are required for the huge-thermal mass nodes. In warming up season, **thermal mass needs to be adjusted lower enough** for ground nodes to easily find the normal temperature range, and **temperature of the boundary condition nodes should be updated every time interval** with other reasonable simulation results.

These problems were reflected to the codes, but since the accuracy isn't high enough and the assumptions are way too simple, more updates for the codes are needed.



+) 4-4-4 model with same method

![4-4-4](https://user-images.githubusercontent.com/82522118/117623624-fb17d100-b1ae-11eb-8bf2-840cedb62a71.jpg)
