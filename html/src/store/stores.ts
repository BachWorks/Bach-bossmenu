import { writable, type Writable } from "svelte/store";

// Gem CID
export const empSourceStore = writable(null);
// Test Users And Grades
export const visibility = writable(false);
export const users: Writable<Array<any>> = writable([
  {
    name: "Test Bruger",
    empSource: "45654",
    gradeLevel: 5,
    gradeLabel: "Sejt",
    online: "🟢",
    isboss: true,
    jobname: "test",
  },
  {
    name: "Test Bruger",
    empSource: "45655",
    gradeLevel: 5,
    gradeLabel: "Sejt1",
    online: "🟢",
    isboss: false,
    jobname: "test",
  },
]);

export const gradeList: Writable<Array<any>> = writable([
  {
    id: 1,
    navn: "TEST",
  },
  {
    id: 2,
    navn: "TEST 2",
  },
  {
    id: 3,
    navn: "TEST 3",
  },
  {
    id: 4,
    navn: "TEST 4",
  },
]);

export const nearByPlayers: Writable<Array<any>> = writable([
  {
    id: 1,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 2,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564565",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 3,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564566",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 4,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564567",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
]);

//  Kasse/Society
export const firmaKasse: Writable<Array<any>> = writable([100]);
export const firmaKasseLOG: Writable<Array<any>> = writable([
  {
    id: 1,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 2,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 3,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 4,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 5,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 6,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 7,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
  {
    id: 8,
    coords: "lort",
    name: "Peter Pedal",
    citizenid: "564564",
    sources: "SOURCE",
    sourceplayer: "Andet Source",
  },
]);

// export const groupname = writable(null);

// interface IStages {
//   name: string,
//   empSource: string,
//   grade: string,
//   gradeLabel: string,
//   online: string,
//   isboss: boolean
//   jobname: string,
// }

// export const users = writable<IStages[]>([])
