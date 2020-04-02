var module = angular.module('superHeroesApp', []);

interface ISuperHero {
  id: number;
  name: string;
}

const SUPERHEROS: ISuperHero[] = [
  { id: 11, name: 'Mr. Nice' },
  { id: 12, name: 'Narco' },
  { id: 13, name: 'Bombasto' },
  { id: 14, name: 'Celeritas' },
  { id: 15, name: 'Magneta' },
  { id: 16, name: 'RubberMan' },
  { id: 17, name: 'Dynama' },
  { id: 18, name: 'Dr IQ' },
  { id: 19, name: 'Magma' },
  { id: 20, name: 'Tornado' },
  { id: 21, name: 'Superman'}
];

class SuperHerosComponentController implements ng.IController {

  public heros: ISuperHero[];

  constructor() {}

  public $onInit () {
    this.heros = SUPERHEROS;
  }
}

class SuperHerosComponent implements ng.IComponentOptions {

  public controller: ng.Injectable<ng.IControllerConstructor>;
  public controllerAs: string;
  public template: string;

  constructor() {
    this.controller = SuperHerosComponentController;
    this.controllerAs = "$ctrl";
    this.template = `
      <ul>
        <li ng-repeat="hero in $ctrl.heros">{{ hero.name }}</li>
      </ul>
    `;
  }
}

angular
  .module("mySuperAwesomeApp", [])
  .component("superheros", new SuperHerosComponent());

angular.element(document).ready(function() {
  angular.bootstrap(document, ["mySuperAwesomeApp"]);
});