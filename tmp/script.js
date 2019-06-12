// ==UserScript==
// @name         Gizmo
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        https://www.explorelearning.com/index.cfm*
// @grant        none
// ==/UserScript==


(function() {
    document.getElementsByClassName('title')[1].text = 'Review: Calorimetry and Rates of Reactions';
    document.getElementsByClassName('sub-title')[0].text = 'Brush up on your previously learned skills. Investigate how calorimetry can be used to find relative specific heat values when different substances are mixed with water.  Modify initial mass and temperature values to see effects on the system.  One or any combination of the substances can be mixed with water.  A dynamic graph (temperature vs. time) shows temperatures of the individual substances after mixing.';

    document.getElementsByClassName('title')[2].text = 'Review: Acids, Bases, and Equilibrium';
    document.getElementsByClassName('sub-title')[1].text = 'Brush up on your previously learned skills. Observe how reactants and products interact in reversible reactions. The initial amount of each substance can be manipulated, as well as the pressure on the chamber. The amounts, concentrations, and partial pressures of each reactant and product can be tracked over time as the reaction proceeds toward equilibrium.';

    document.getElementsByClassName('title')[3].text = 'Review: Electrochemistry';
    document.getElementsByClassName('sub-title')[2].text = 'Brush up on your previously learned skills. Investigate how electrons are transferred in reduction and oxidation reactions. Discover the mechanism and applications of the Galvanic cell.'
})();
