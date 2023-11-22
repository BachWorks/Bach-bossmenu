<script lang="ts">
  import { visibility } from "../store/stores";
  import { fetchNui } from "../utils/fetchNui";
  import { onMount } from "svelte";
  import "@fortawesome/fontawesome-free/css/all.min.css";
  import {
    users,
    gradeList,
    nearByPlayers,
    firmaKasse,
    firmaKasseLOG,
  } from "../store/stores";

  let selectedGrade = gradeList;
  let jobLabel = "";
  let employeesShow = false;
  let hireShow = false;
  let stashShow = false;
  let overviewShow = true;
  let clientisBoss = true;
  let moneyShow = false;
  let isModalOpen = false;
  let showTransactions = false;
  let showInsertInput = false;
  let showWithdrawInput = false;
  let chooseHW = false;
  let amount = 0;
  let amountWithJob = 0;

  function togglechooseHW() {
    chooseHW = !chooseHW;
  }

  function toggleInput(inputType: string) {
    if (inputType === "insert") {
      showInsertInput = !showInsertInput;
      showWithdrawInput = false;
    } else if (inputType === "withdraw") {
      showWithdrawInput = !showWithdrawInput;
      showInsertInput = false;
    }
  }

  function toggleBOTH() {
    showWithdrawInput = true;
    showInsertInput = true;
  }

  function amountZero() {
    amount = 0;
  }

  // Const's

  const toggleVisibility = (type: string) => {
    employeesShow = type === "employees";
    hireShow = type === "hire";
    stashShow = type === "stash";
    overviewShow = type === "overview";
    moneyShow = type === "money";
  };

  const getJob = async () => {
    try {
      const response = await fetchNui("bach-bossmenu:getJob", {});
      jobLabel = response;
    } catch (error) {
      console.error(error);
    }
  };

  const getEmployees = async () => {
    try {
      // Table clea
      const response = await fetchNui("bach-bossmenu:getEmployees", {});
      users.set(response);
    } catch (error) {
      console.error(error);
    }
  };

  const getAccount = async () => {
    try {
      const response = await fetchNui("bach-bossmenu:getAccount", {});
      firmaKasse.set(response);
    } catch (error) {
      console.error(error);
    }
  };

  const getNearbyPlayers = async () => {
    try {
      // Table clea
      const response = await fetchNui("bach-bossmenu:getNearbyPlayers", {});
      nearByPlayers.set(response);
    } catch (error) {
      console.error(error);
    }
  };

  const getBOSS = async () => {
    try {
      const response = await fetchNui("bach-bossmenu:getBOSS", {});
      clientisBoss = response;
    } catch (error) {
      console.error(error);
    }
  };

  const getRanks = async () => {
    try {
      const response = await fetchNui("bach-bossmenu:getRanks", {});
      gradeList.set(response);
    } catch (error) {
      console.error(error);
    }
  };

  const handleClick = async (section: string) => {
    toggleVisibility(section);
    await getBOSS();
    await getJob();
    await getEmployees();

    if (section === "hire") {
      getNearbyPlayers();
    }
    if (section === "money") {
      getAccount();
    }
  };

  const getAmountWithJob = async () => {
    try {
      const response = await fetchNui("bach-bossmenu:getEmployeesAmount", {});
      amountWithJob = response;
    } catch (error) {
      console.error(error);
    }
  };


  // Money stuff

  function toggleTransactions() {
    showTransactions = !showTransactions;
  }

  function handleMoney(choosen: string) {
    if (choosen === "heav") {
      choosen = "heav";
      fetchNui("bach-bossmenu:moneyDep", { amount, choosen });
      amount = 0;
    }
    if (choosen === "indseat") {
      choosen = "indseat";
      fetchNui("bach-bossmenu:moneyDep", { amount, choosen });
      amount = 0;
    }
  }

  function handlePersonal(choosen: string) {
    if (choosen === "stash") {
      fetchNui("bach-bossmenu:personalHandle", { choosen });
      amount = 0;
    }
    if (choosen === "outfits") {
      fetchNui("bach-bossmenu:personalHandle", { choosen });
    }
  }

  function openModal() {
    isModalOpen = true;
  }

  function closeModal() {
    isModalOpen = false;
  }

  function handleActionGrades(cid: string, grade: number, gradename: string) {
    fetchNui("bach-bossmenu:updateGrade", { cid, grade, gradename });
    closeModal();
  }

  function handleAction(source: string) {
    fetchNui("bach-bossmenu:fireEmployee", { source });
    closeModal();
  }

  function handleHire(source: string) {
    fetchNui("bach-bossmenu:hireEmployee", { source });
    closeModal();
  }

  onMount(async () => {
    toggleVisibility("overview");
    await getJob();
    await getAmountWithJob();
  });
</script>

<div class="container">
<div class="h-screen w-screen overflow-x-hidden overflow-y-hidden flex justify-center items-center">
    <div class="w-[62vw] h-[43vw] max-h-[43vw] bg-[#232323] relative flex z-20">

      <div id="mySidenav" class="sidenav z-20 ">
        <div class="hoverable-sidebar z-20 ">
          <span class="neger z-20">BOSSMENU</span>
          {#each ["overview", "employees", "transactions", "money"] as section}
            <button
              class="button relative overflow-hidden rounded-lg right-1 bg-[#0F0F0F] text-white px-1 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:bg-neutral-800 hover:text-white group"
              on:click={() => handleClick(section)}
            >
              {#if section === "overview"}
                <a class="z-20"><i class="bi bi-house-door-fill mr-5"></i>Oversigt</a>
              {:else if section === "employees"}
                <a class="z-20"><i class="bi bi-people-fill mr-5 "></i>Ansatte</a>
              {:else if section === "transactions"}
                <a class="z-20"><i class="bi bi-receipt mr-5"></i>Transaktioner</a>
              {:else if section === "money"}
                <a class="z-20"><i class="bi bi-currency-exchange mr-5"></i>Konto</a>
              {/if}
            </button>
          {/each}
          </div>
        </div>
  
  {#if overviewShow}

          <div id="main" class="z-10 p-8 w-full h-full flex flex-col gap-4">
            <div class="h-20 w-full text-white">
                <span class="font-bold text-3xl text-white uppercase">Oversigt</span>
            </div>
            <div class="w-full h-screen flex flex-row gap-4">
                <div class="w-1/3 h-24 bg-[#303030] border-2 border-[#3D3D3D] rounded-xl">
                    <div class="w-full h-8 px-2 border-b-2 border-[#3D3D3D]">
                        <span class="text-white text-lg">Firmakasse</span>

                    </div>
                    <div class="w-full h-14 px-2 flex items-center">
                        <span class="text-white text-3xl font-semibold">{$firmaKasse} DKK</span>
                    </div>
                </div>
                <div class="w-1/3 h-24 bg-[#303030] border-2 border-[#3D3D3D] rounded-xl"></div>
                <div class="w-1/3 h-24 bg-[#303030] border-2 border-[#3D3D3D] rounded-xl"></div>

            </div>
        </div>



  {:else if employeesShow}

        <div id="main" class="z-10 p-8 w-full h-full flex flex-col gap-4">
            <div class="h-20 z-10 w-full text-white">
                <span class="font-bold text-3xl text-white uppercase">ANSATTE</span>
            </div>
            <div class="w-full h-screen overflow-y-auto gap-4  z-10">
                  {#each $users as { name, empSource, gradeLabel, online, isboss }, index (gradeLabel)}

                <div class="w-[95%] z-10 h-20 bg-[#111111] rounded-xl flex flex-row justify-between">
                    <div class="w-80  z-10 flex flex-row">
                        <div class="w-20 h-20 flex justify-center items-center  z-10">
                            <div class="rounded-full bg-green-500 w-8 h-8"></div>
                        </div>
    
                        <div class="w-4 h-4 flex justify-center items-center">
                        </div>
    
                        <div class="w-52 h-20 flex justify-center items-center flex-col">
                            <div class="w-full h-full flex flex-col justify-center items-start">
                                <span class="text-white font-semibold text-2xl leading-6">Navn Navn</span>
                                <span class="text-white text-lg leading-5">Stilling</span>
                            </div>
                        </div>
                    </div>


                    <div class="w-48 h-full flex justify-center items-center">
                        <button class="w-[80%] rounded-md h-12 my-8 bg-[#303030] from-[#8B5CF6] to-[#3c06b9] flex justify-center items-center" on:click={() => {
                  openModal();
                  getRanks();
                }}>
                            <span class="text-white text-xl font-bold">REDIGER</span>
                        </button>
                    </div>
                </div>



            {#if isModalOpen}

    <div class="fixed z-20 inset-0 bg-neutral-700 bg-opacity-25 flex items-center justify-center">
        <div class="bg-[#0F0F0F] w-[500px] h-[200px] p-8 rounded shadow-lg text-white rounded-lg space-y-2">
          <h2 class="text-xl mb-4">Edit worker</h2>

          <div class="w-full h-20">
            <div>

              <label for="grades">Choose Rank:</label>
              <select
                class="bg-[#0F0F0F] round-lg"
                bind:value={selectedGrade}
              >w
                {#each $gradeList as grade (grade.id)}
                  <option class="bg-[#0F0F0F] round-lg" value={grade}
                    >{grade.navn}</option
                  >
                {/each}
              </select>
            </div>
          </div>
          <div class="w-full h-10 flex items-center justify-end gap-2">
            <button  on:click={closeModal} class="bg-neutral-600 h-8 w-20 text-white px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-neutral-900"><i class="fas fa-x text-white" /> Cancel</button>
            <button on:click={() => handleAction(empSource)} class="bg-red-900 text-white w-20 px-4 py-2 h-8 mr-0 rounded transition duration-300 ease-in-out hover:bg-red-500"> <i class="fas fa-user-minus text-white"/>  Fire</button>
            <button on:click={() => {handleActionGrades(empSource, selectedGrade.id, selectedGrade.navn);}} class="bg-green-800 w-48 h-8 text-white px-5 py-2 rounded transition duration-300 ease-in-out hover:bg-green-500"><i class="fas fa-user-plus text-white" /> Update worker rank</button>
          </div>


        </div>
      </div>
          {/if}
                <div class="w-full h-4"></div>
             {/each}

            </div>
        </div>


  {:else if hireShow}
    <!--  Færdig -->
    <h1 class="text-2xl text-white mb-5 px-9 font-mono">PLAYERS NEARBY</h1>

    <div class="user-container">
      {#each $nearByPlayers as { id, name, citizenid, sources, sourceplayer }, index (citizenid)}
        <div class="mb-4 py-6 bg-neutral-700 p-6 rounded-lg shadow-lg">
          <div class="grid grid-cols-7 gap-1">
            <h3 class="text-2xl text-white mb-2 px-9">ID: {id}</h3>
            <h3 class="text-base text-white">Name: {name}.</h3>
            <h3 class="text-base text-white">CID: {citizenid}.</h3>

            {#if clientisBoss}
              <button
                class="button relative overflow-hidden text-blue-300 px-5 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:rotate-2 hover:text-white group"
                on:click={() => {
                  openModal();
                  getRanks();
                }}
              >
                <i class="fa-solid fa-user-pen text-xl" />
                <span
                  class="absolute top-0 left-4 w-full h-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
                />
              </button>
            {/if}

            <div class="col-span-2 flex items-center justify-start" />
          </div>

          {#if isModalOpen}
            <div
              class="fixed inset-0 bg-neutral-700 bg-opacity-25 flex items-center justify-center"
            >
              <div
                class="bg-[#0F0F0F] p-8 rounded shadow-lg text-white rounded-lg space-y-2"
              >
                <h2 class="text-xl mb-4">Select An Action</h2>
                <button
                  on:click={() => handleHire(id)}
                  class="bg-green-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-green-200"
                >
                  <i class="fas fa-user-plus text-white" />
                  Hire
                </button>
                <div>
                  <button
                    on:click={closeModal}
                    class="bg-neutral-600 text-white px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
                  >
                    <i class="fas fa-x text-white" />
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          {/if}

          {#if index % 5 === 4}
            <div class="user-container" />
          {/if}
        </div>
      {/each}
    </div>
  {:else if overviewShow}
    <h2 class="text-3xl font-bold mb-4">Company Account</h2>
    <div class="flex items-center">
      <i class="fas fa-money-bill text-xl mr-2 animate-pulse" />
      <span class="text-2xl">${$firmaKasse}</span>
    </div>

    <h2 class="text-2xl font-bold mt-8 mb-4">Number Of Employees</h2>
    <div class="flex items-center">
      <i class="fas fa-user-check text-xl mr-2 animate-pulse" />
      <span class="text-2xl">{amountWithJob} Employee(s)</span>
    </div>
  {:else if moneyShow}
    <!-- Penge Side -->
    <h2 class="absolute text-3xl font-bold mb-4 mb-[40%]">COMPANY MONEY</h2>
    <div class="absolute flex items-center mb-[34%] ml-[-2.5%]">
      <i class="fas fa-money-bill text-xl mr-2 animate-pulse" />
      <span class="text-2xl">${$firmaKasse}</span>
    </div>

    <div class="absolute top-0 left-0 ml-[60%] mt-[2.5%]">
      <div class="flex items-center">
        <!-- Not done (Bach) -->
        
        <!-- <button
          class="ml-2 mr-2 bg-blue-500 text-white px-3 py-1 rounded transition duration-300 ease-in-out hover:bg-blue-700"
          on:click={toggleTransactions}
        >
          {#if showTransactions}
          Hide Transactions
          {:else}
          View Transactions
          {/if}
        </button> -->

        <button
          on:click={() => {
            togglechooseHW();
            if (showTransactions) {
              toggleTransactions();
            }
          }}
          class="ml-2 mr-2 bg-blue-500 text-white px-3 py-1 rounded transition duration-300 ease-in-out hover:bg-blue-700"
        >
        Actions
        </button>
      </div>
    </div>

    {#if chooseHW}
      <div
        class="fixed inset-0 bg-neutral-700 bg-opacity-25 flex items-center justify-center"
      >
        <div
          class="bg-[#0F0F0F] p-8 rounded shadow-lg text-white rounded-lg space-y-0 space-x-1"
        >
          <h2 class="text-xl mb-4">Select An Action</h2>
          <button
            on:click={() => toggleInput("insert")}
            class="bg-green-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-green-200"
          >
          Deposit
          </button>
          <button
            on:click={() => toggleInput("withdraw")}
            class="bg-red-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-red-200"
          >
          Withdraw
          </button>
          <div>
            <button
              on:click={togglechooseHW}
              class="bg-neutral-600 text-white px-4 py-2 mt-2 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    {/if}

    <!-- Hæv Og Indsæt -->

    {#if showInsertInput}
      <div
        class="fixed inset-0 bg-neutral-700 bg-opacity-25 flex items-center justify-center"
      >
        <div
          class="bg-[#0F0F0F] p-8 rounded shadow-lg text-[#FFF] rounded-lg space-y-2"
        >
          <h2 class="text-xl mb-4">Enter Amount for Deposit</h2>
          <input
            type="number"
            class="border rounded px-2 py-1 text-[#000000]"
            placeholder="Beløb"
            bind:value={amount}
          />
          <div>
            <button
              on:click={() => {
                toggleBOTH();
                amountZero();
              }}
              class="bg-neutral-600 text-[#FFF] px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
            >
              Cancel
            </button>
            <button
              on:click={() => {
                toggleBOTH();
                handleMoney("indseat");
              }}
              class="bg-green-500 text-[#FFF] px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-green-700"
            >
            Deposit
            </button>
          </div>
        </div>
      </div>
    {/if}

    {#if showWithdrawInput}
      <div
        class="fixed inset-0 bg-neutral-700 bg-opacity-25 flex items-center justify-center"
      >
        <div
          class="bg-[#0F0F0F] p-8 rounded shadow-lg text-[#FFF] rounded-lg space-y-2"
        >
          <h2 class="text-xl mb-4">Enter Amount for Withdrawal</h2>
          <input
            type="number"
            class="border rounded px-2 py-1 text-[#000000]"
            placeholder="Beløb"
            bind:value={amount}
          />
          <div>
            <button
              on:click={() => {
                toggleBOTH();
                amountZero();
              }}
              class="bg-neutral-600 text-[#FFF] px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
            >
              Cancel
            </button>
            <button
              on:click={() => {
                toggleBOTH();
                handleMoney("heav");
              }}
              class="bg-green-500 text-[#FFF] px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-green-700"
            >
            Withdraw
            </button>
          </div>
        </div>
      </div>
    {/if}

    <!-- SHIIII  -->

    <div class="money-container">
      {#if showTransactions}
        {#each $firmaKasseLOG as { name, id }, index (id)}
          <div class="mb-4 py-6 bg-neutral-700 p-6 rounded-lg shadow-lg">
            <div class="grid grid-cols-7 gap-1">
              <h3 class="text-2xl text-white mb-2 px-7">{id}</h3>
              <h3 class="text-base text-white">Name: {name}.</h3>

              {#if clientisBoss}
                <button
                  class="button relative overflow-hidden text-blue-300 px-5 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:rotate-2 hover:text-white group"
                  on:click={() => {
                    openModal();
                    getRanks();
                  }}
                >
                  <i class="fa-solid fa-circle-info text-xl" />
                  <span
                    class="absolute top-0 left-4 w-full h-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
                  />
                </button>
              {/if}
            </div>
          </div>
        {/each}
      {/if}
    </div>
    <!-- Lager Og Outfits -->
  {:else if stashShow}
    <!-- <h1 class="text-5xl text-white mb-5 px-9 font-mono mb-[40%]">SIMPLE TING</h1> -->
    <div class="flex space-x-10 text-xl flex items-center justify-center">
      <button
      on:click={() => {
        handlePersonal("stash");
      }}
        class="bg-blue-500 text-white px-10 py-5 rounded-md transition duration-300 ease-in-out hover:shadow-xl hover:scale-105 transform focus:outline-none"
      >
        <i class="fas fa-box-open text-white mr-2" />
        Company Stock
      </button>

      <button
      on:click={() => {
        handlePersonal("outfits");
      }}
        class="bg-blue-500 text-white px-10 py-5 rounded-md transition duration-300 ease-in-out hover:shadow-xl hover:scale-105 transform focus:outline-none"
      >
        <i class="fas fa-tshirt text-white mr-2" />
        Your Outfits
      </button>
    </div>
  {/if}
        </div>

</div>
</div>

<style>

/* Adjust main content position */
#testmain {
  margin-left: 75px; /* Adjust as needed */
  margin-right: 25px; /* Adjust as needed */
  transition: margin-left 0.5s;
}

/*
! tailwindcss v3.3.3 | MIT License | https://tailwindcss.com
*/

/*
1. Prevent padding and border from affecting element width. (https://github.com/mozdevs/cssremedy/issues/4)
2. Allow adding a border to an element by just adding a border-width. (https://github.com/tailwindcss/tailwindcss/pull/116)
*/

*,
::before,
::after {
  box-sizing: border-box;
  /* 1 */
  border-width: 0;
  /* 2 */
  border-style: solid;
  /* 2 */
  border-color: #e5e7eb;
  /* 2 */
}

::before,
::after {
  --tw-content: '';
}

/*
1. Use a consistent sensible line-height in all browsers.
2. Prevent adjustments of font size after orientation changes in iOS.
3. Use a more readable tab size.
4. Use the user's configured `sans` font-family by default.
5. Use the user's configured `sans` font-feature-settings by default.
6. Use the user's configured `sans` font-variation-settings by default.
*/

html {
  line-height: 1.5;
  /* 1 */
  -webkit-text-size-adjust: 100%;
  /* 2 */
  -moz-tab-size: 4;
  /* 3 */
  -o-tab-size: 4;
     tab-size: 4;
  /* 3 */
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
  /* 4 */
  font-feature-settings: normal;
  /* 5 */
  font-variation-settings: normal;
  /* 6 */
}

/*
1. Remove the margin in all browsers.
2. Inherit line-height from `html` so users can set them as a class directly on the `html` element.
*/

body {
  margin: 0;
  /* 1 */
  line-height: inherit;
  /* 2 */
}

/*
1. Add the correct height in Firefox.
2. Correct the inheritance of border color in Firefox. (https://bugzilla.mozilla.org/show_bug.cgi?id=190655)
3. Ensure horizontal rules are visible by default.
*/

hr {
  height: 0;
  /* 1 */
  color: inherit;
  /* 2 */
  border-top-width: 1px;
  /* 3 */
}

/*
Add the correct text decoration in Chrome, Edge, and Safari.
*/

abbr:where([title]) {
  -webkit-text-decoration: underline dotted;
          text-decoration: underline dotted;
}

/*
Remove the default font size and weight for headings.
*/

h1,
h2,
h3,
h4,
h5,
h6 {
  font-size: inherit;
  font-weight: inherit;
}

/*
Reset links to optimize for opt-in styling instead of opt-out.
*/

a {
  color: inherit;
  text-decoration: inherit;
}

/*
Add the correct font weight in Edge and Safari.
*/

b,
strong {
  font-weight: bolder;
}

/*
1. Use the user's configured `mono` font family by default.
2. Correct the odd `em` font sizing in all browsers.
*/

code,
kbd,
samp,
pre {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  /* 1 */
  font-size: 1em;
  /* 2 */
}

/*
Add the correct font size in all browsers.
*/

small {
  font-size: 80%;
}

/*
Prevent `sub` and `sup` elements from affecting the line height in all browsers.
*/

sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub {
  bottom: -0.25em;
}

sup {
  top: -0.5em;
}

/*
1. Remove text indentation from table contents in Chrome and Safari. (https://bugs.chromium.org/p/chromium/issues/detail?id=999088, https://bugs.webkit.org/show_bug.cgi?id=201297)
2. Correct table border color inheritance in all Chrome and Safari. (https://bugs.chromium.org/p/chromium/issues/detail?id=935729, https://bugs.webkit.org/show_bug.cgi?id=195016)
3. Remove gaps between table borders by default.
*/

table {
  text-indent: 0;
  /* 1 */
  border-color: inherit;
  /* 2 */
  border-collapse: collapse;
  /* 3 */
}

/*
1. Change the font styles in all browsers.
2. Remove the margin in Firefox and Safari.
3. Remove default padding in all browsers.
*/

button,
input,
optgroup,
select,
textarea {
  font-family: inherit;
  /* 1 */
  font-feature-settings: inherit;
  /* 1 */
  font-variation-settings: inherit;
  /* 1 */
  font-size: 100%;
  /* 1 */
  font-weight: inherit;
  /* 1 */
  line-height: inherit;
  /* 1 */
  color: inherit;
  /* 1 */
  margin: 0;
  /* 2 */
  padding: 0;
  /* 3 */
}

/*
Remove the inheritance of text transform in Edge and Firefox.
*/

button,
select {
  text-transform: none;
}

/*
1. Correct the inability to style clickable types in iOS and Safari.
2. Remove default button styles.
*/

button,
[type='button'],
[type='reset'],
[type='submit'] {
  -webkit-appearance: button;
  /* 1 */
  background-color: transparent;
  /* 2 */
  background-image: none;
  /* 2 */
}

/*
Use the modern Firefox focus style for all focusable elements.
*/

:-moz-focusring {
  outline: auto;
}

/*
Remove the additional `:invalid` styles in Firefox. (https://github.com/mozilla/gecko-dev/blob/2f9eacd9d3d995c937b4251a5557d95d494c9be1/layout/style/res/forms.css#L728-L737)
*/

:-moz-ui-invalid {
  box-shadow: none;
}

/*
Add the correct vertical alignment in Chrome and Firefox.
*/

progress {
  vertical-align: baseline;
}

/*
Correct the cursor style of increment and decrement buttons in Safari.
*/

::-webkit-inner-spin-button,
::-webkit-outer-spin-button {
  height: auto;
}

/*
1. Correct the odd appearance in Chrome and Safari.
2. Correct the outline style in Safari.
*/

[type='search'] {
  -webkit-appearance: textfield;
  /* 1 */
  outline-offset: -2px;
  /* 2 */
}

/*
Remove the inner padding in Chrome and Safari on macOS.
*/

::-webkit-search-decoration {
  -webkit-appearance: none;
}

/*
1. Correct the inability to style clickable types in iOS and Safari.
2. Change font properties to `inherit` in Safari.
*/

::-webkit-file-upload-button {
  -webkit-appearance: button;
  /* 1 */
  font: inherit;
  /* 2 */
}

/*
Add the correct display in Chrome and Safari.
*/

summary {
  display: list-item;
}

/*
Removes the default spacing and border for appropriate elements.
*/

blockquote,
dl,
dd,
h1,
h2,
h3,
h4,
h5,
h6,
hr,
figure,
p,
pre {
  margin: 0;
}

fieldset {
  margin: 0;
  padding: 0;
}

legend {
  padding: 0;
}

ol,
ul,
menu {
  list-style: none;
  margin: 0;
  padding: 0;
}

/*
Reset default styling for dialogs.
*/

dialog {
  padding: 0;
}

/*
Prevent resizing textareas horizontally by default.
*/

textarea {
  resize: vertical;
}

/*
1. Reset the default placeholder opacity in Firefox. (https://github.com/tailwindlabs/tailwindcss/issues/3300)
2. Set the default placeholder color to the user's configured gray 400 color.
*/

input::-moz-placeholder, textarea::-moz-placeholder {
  opacity: 1;
  /* 1 */
  color: #9ca3af;
  /* 2 */
}

input::placeholder,
textarea::placeholder {
  opacity: 1;
  /* 1 */
  color: #9ca3af;
  /* 2 */
}

/*
Set the default cursor for buttons.
*/

button,
[role="button"] {
  cursor: pointer;
}

/*
Make sure disabled buttons don't get the pointer cursor.
*/

:disabled {
  cursor: default;
}

/*
1. Make replaced elements `display: block` by default. (https://github.com/mozdevs/cssremedy/issues/14)
2. Add `vertical-align: middle` to align replaced elements more sensibly by default. (https://github.com/jensimmons/cssremedy/issues/14#issuecomment-634934210)
   This can trigger a poorly considered lint error in some tools but is included by design.
*/

img,
svg,
video,
canvas,
audio,
iframe,
embed,
object {
  display: block;
  /* 1 */
  vertical-align: middle;
  /* 2 */
}

/*
Constrain images and videos to the parent width and preserve their intrinsic aspect ratio. (https://github.com/mozdevs/cssremedy/issues/14)
*/

img,
video {
  max-width: 100%;
  height: auto;
}

/* Make elements with the HTML hidden attribute stay hidden by default */

[hidden] {
  display: none;
}

*, ::before, ::after {
  --tw-border-spacing-x: 0;
  --tw-border-spacing-y: 0;
  --tw-translate-x: 0;
  --tw-translate-y: 0;
  --tw-rotate: 0;
  --tw-skew-x: 0;
  --tw-skew-y: 0;
  --tw-scale-x: 1;
  --tw-scale-y: 1;
  --tw-pan-x:  ;
  --tw-pan-y:  ;
  --tw-pinch-zoom:  ;
  --tw-scroll-snap-strictness: proximity;
  --tw-gradient-from-position:  ;
  --tw-gradient-via-position:  ;
  --tw-gradient-to-position:  ;
  --tw-ordinal:  ;
  --tw-slashed-zero:  ;
  --tw-numeric-figure:  ;
  --tw-numeric-spacing:  ;
  --tw-numeric-fraction:  ;
  --tw-ring-inset:  ;
  --tw-ring-offset-width: 0px;
  --tw-ring-offset-color: #fff;
  --tw-ring-color: rgb(59 130 246 / 0.5);
  --tw-ring-offset-shadow: 0 0 #0000;
  --tw-ring-shadow: 0 0 #0000;
  --tw-shadow: 0 0 #0000;
  --tw-shadow-colored: 0 0 #0000;
  --tw-blur:  ;
  --tw-brightness:  ;
  --tw-contrast:  ;
  --tw-grayscale:  ;
  --tw-hue-rotate:  ;
  --tw-invert:  ;
  --tw-saturate:  ;
  --tw-sepia:  ;
  --tw-drop-shadow:  ;
  --tw-backdrop-blur:  ;
  --tw-backdrop-brightness:  ;
  --tw-backdrop-contrast:  ;
  --tw-backdrop-grayscale:  ;
  --tw-backdrop-hue-rotate:  ;
  --tw-backdrop-invert:  ;
  --tw-backdrop-opacity:  ;
  --tw-backdrop-saturate:  ;
  --tw-backdrop-sepia:  ;
}

::backdrop {
  --tw-border-spacing-x: 0;
  --tw-border-spacing-y: 0;
  --tw-translate-x: 0;
  --tw-translate-y: 0;
  --tw-rotate: 0;
  --tw-skew-x: 0;
  --tw-skew-y: 0;
  --tw-scale-x: 1;
  --tw-scale-y: 1;
  --tw-pan-x:  ;
  --tw-pan-y:  ;
  --tw-pinch-zoom:  ;
  --tw-scroll-snap-strictness: proximity;
  --tw-gradient-from-position:  ;
  --tw-gradient-via-position:  ;
  --tw-gradient-to-position:  ;
  --tw-ordinal:  ;
  --tw-slashed-zero:  ;
  --tw-numeric-figure:  ;
  --tw-numeric-spacing:  ;
  --tw-numeric-fraction:  ;
  --tw-ring-inset:  ;
  --tw-ring-offset-width: 0px;
  --tw-ring-offset-color: #fff;
  --tw-ring-color: rgb(59 130 246 / 0.5);
  --tw-ring-offset-shadow: 0 0 #0000;
  --tw-ring-shadow: 0 0 #0000;
  --tw-shadow: 0 0 #0000;
  --tw-shadow-colored: 0 0 #0000;
  --tw-blur:  ;
  --tw-brightness:  ;
  --tw-contrast:  ;
  --tw-grayscale:  ;
  --tw-hue-rotate:  ;
  --tw-invert:  ;
  --tw-saturate:  ;
  --tw-sepia:  ;
  --tw-drop-shadow:  ;
  --tw-backdrop-blur:  ;
  --tw-backdrop-brightness:  ;
  --tw-backdrop-contrast:  ;
  --tw-backdrop-grayscale:  ;
  --tw-backdrop-hue-rotate:  ;
  --tw-backdrop-invert:  ;
  --tw-backdrop-opacity:  ;
  --tw-backdrop-saturate:  ;
  --tw-backdrop-sepia:  ;
}

.static {
  position: static;
}

.fixed {
  position: fixed;
}

.absolute {
  position: absolute;
}

.relative {
  position: relative;
}

.inset-0 {
  inset: 0px;
}

.bottom-0 {
  bottom: 0px;
}

.z-10 {
  z-index: 10;
}

.z-20 {
  z-index: 20;
}

.z-30 {
  z-index: 30;
}

.-z-30 {
  z-index: -30;
}

.z-40 {
  z-index: 40;
}

.bg-green-800 {
  --tw-bg-opacity: 1;
  background-color: rgb(22 101 52 / var(--tw-bg-opacity));
}

.bg-neutral-600 {
  --tw-bg-opacity: 1;
  background-color: rgb(82 82 82 / var(--tw-bg-opacity));
}

.bg-neutral-700 {
  --tw-bg-opacity: 1;
  background-color: rgb(64 64 64 / var(--tw-bg-opacity));
}

.bg-red-900 {
  --tw-bg-opacity: 1;
  background-color: rgb(127 29 29 / var(--tw-bg-opacity));
}

.bg-opacity-25 {
  --tw-bg-opacity: 0.25;
}


.-z-50 {
  z-index: -50;
}

.z-60 {
  z-index: 60;
}

.-ml-14 {
  margin-left: -3.5rem;
}

.-ml-\[1\%\] {
  margin-left: -1%;
}

.-ml-\[15\%\] {
  margin-left: -15%;
}

.-mr-14 {
  margin-right: -3.5rem;
}

.-mt-\[70px\] {
  margin-top: -70px;
}

.ml-\[11\%\] {
  margin-left: 11%;
}

.ml-\[15\%\] {
  margin-left: 15%;
}

.mt-32 {
  margin-top: 8rem;
}

.ml-16 {
  margin-left: 4rem;
}

.ml-\[60px\] {
  margin-left: 60px;
}

.ml-24 {
  margin-left: 6rem;
}

.mr-2 {
  margin-right: 0.5rem;
}

.mr-3 {
  margin-right: 0.75rem;
}

.mr-4 {
  margin-right: 1rem;
}

.mt-16 {
  margin-top: 4rem;
}

.mt-8 {
  margin-top: 2rem;
}

.ml-14 {
  margin-left: 3.5rem;
}

.ml-12 {
  margin-left: 3rem;
}

.mr-5 {
  margin-right: 1.25rem;
}

.block {
  display: block;
}

.flex {
  display: flex;
}

.h-10 {
  height: 2.5rem;
}

.h-12 {
  height: 3rem;
}

.h-16 {
  height: 4rem;
}

.h-20 {
  height: 5rem;
}

.h-28 {
  height: 7rem;
}

.h-36 {
  height: 9rem;
}

.h-52 {
  height: 13rem;
}

.h-8 {
  height: 2rem;
}

.h-96 {
  height: 24rem;
}

.h-\[200px\] {
  height: 200px;
}

.h-\[250px\] {
  height: 250px;
}

.h-\[300px\] {
  height: 300px;
}

.h-\[300px\] {
  height: 400px;
}

.h-\[28px\] {
  height: 28px;
}

.h-\[50px\] {
  height: 50px;
}

.h-\[520px\] {
  height: 520px;
}

.h-\[600px\] {
  height: 600px;
}

.h-\[750px\] {
  height: 750px;
}

.h-\[800px\] {
  height: 800px;
}

.h-\[82px\] {
  height: 82px;
}

.h-\[900px\] {
  height: 900px;
}

.h-\[90px\] {
  height: 90px;
}

.h-full {
  height: 100%;
}

.h-screen {
  height: 100vh;
}

.h-\[20vw\] {
  height: 20vw;
}

.h-\[30vw\] {
  height: 30vw;
}

.h-\[50vw\] {
  height: 50vw;
}

.h-\[40vw\] {
  height: 40vw;
}

.h-\[43vw\] {
  height: 43vw;
}

.h-fit {
  height: -moz-fit-content;
  height: fit-content;
}

.max-h-\[43vw\] {
  max-height: 43vw;
}

.max-h-96 {
  max-height: 24rem;
}

.w-1\/4 {
  width: 25%;
}

.w-40 {
  width: 10rem;
}

.w-8 {
  width: 2rem;
}

.w-20 {
  width: 5rem;
}



.w-48 {
  width: 12rem;
}

.w-\[129px\] {
  width: 129px;
}

.w-\[130\%\] {
  width: 130%;
}

.w-\[500px\] {
  width: 500px;
}

.w-\[60\%\] {
  width: 60%;
}

.w-\[630px\] {
  width: 630px;
}

.w-full {
  width: 100%;
}

.w-screen {
  width: 100vw;
}

.w-96 {
  width: 24rem;
}

.w-\[60vw\] {
  width: 60vw;
}

.w-\[62vw\] {
  width: 62vw;
}

.min-w-\[129px\] {
  min-width: 129px;
}

.max-w-\[940px\] {
  max-width: 940px;
}

.-rotate-6 {
  --tw-rotate: -6deg;
  transform: translate(var(--tw-translate-x), var(--tw-translate-y)) rotate(var(--tw-rotate)) skewX(var(--tw-skew-x)) skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x)) scaleY(var(--tw-scale-y));
}

.resize {
  resize: both;
}

.flex-row {
  flex-direction: row;
}

.flex-col {
  flex-direction: column;
}

.items-center {
  align-items: center;
}

.justify-center {
  justify-content: center;
}

.justify-between {
  justify-content: space-between;
}

.gap-16 {
  gap: 4rem;
}

.gap-2 {
  gap: 0.5rem;
}

.gap-3 {
  gap: 0.75rem;
}

.gap-4 {
  gap: 1rem;
}

.gap-8 {
  gap: 2rem;
}

.overflow-x-auto {
  overflow-x: auto;
}

.overflow-y-auto {
  overflow-y: auto;
}

.overflow-x-hidden {
  overflow-x: hidden;
}

.overflow-y-hidden {
  overflow-y: hidden;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.rounded-md {
  border-radius: 0.375rem;
}

.rounded-xl {
  border-radius: 0.75rem;
}

.rounded-b-\[100\%\] {
  border-bottom-right-radius: 100%;
  border-bottom-left-radius: 100%;
}

.border {
  border-width: 1px;
}

.border-b-4 {
  border-bottom-width: 4px;
}

.border-t-4 {
  border-top-width: 4px;
}

.border-dashed {
  border-style: dashed;
}

.border-\[\#3849ff\] {
  --tw-border-opacity: 1;
  border-color: rgb(56 73 255 / var(--tw-border-opacity));
}

.border-\[\#3D3D3D\] {
  --tw-border-opacity: 1;
  border-color: rgb(61 61 61 / var(--tw-border-opacity));
}

.rounded-md {
  border-radius: 0.375rem;
}

.rounded-xl {
  border-radius: 0.75rem;
}

.border {
  border-width: 1px;
}

.border-2 {
  border-width: 2px;
}

.border-b {
  border-bottom-width: 1px;
}

.border-b-2 {
  border-bottom-width: 2px;
}

.bg-\[\#0e1627\] {
  --tw-bg-opacity: 1;
  background-color: rgb(14 22 39 / var(--tw-bg-opacity));
}

.bg-\[\#303030\] {
  --tw-bg-opacity: 1;
  background-color: rgb(48 48 48 / var(--tw-bg-opacity));
}



.bg-\[\#282828\] {
  --tw-bg-opacity: 1;
  background-color: rgb(40 40 40 / var(--tw-bg-opacity));
}

.bg-\[\#283d6e\] {
  --tw-bg-opacity: 1;
  background-color: rgb(40 61 110 / var(--tw-bg-opacity));
}

.bg-\[\#283e6d\] {
  --tw-bg-opacity: 1;
  background-color: rgb(40 62 109 / var(--tw-bg-opacity));
}

.bg-\[\#304574\] {
  --tw-bg-opacity: 1;
  background-color: rgb(48 69 116 / var(--tw-bg-opacity));
}

.bg-black {
  --tw-bg-opacity: 1;
  background-color: rgb(0 0 0 / var(--tw-bg-opacity));
}

.bg-black\/\[0\.4\] {
  background-color: rgb(0 0 0 / 0.4);
}

.bg-blue-500 {
  --tw-bg-opacity: 1;
  background-color: rgb(59 130 246 / var(--tw-bg-opacity));
}

.bg-blue-600 {
  --tw-bg-opacity: 1;
  background-color: rgb(37 99 235 / var(--tw-bg-opacity));
}

.bg-\[E6E6FA\] {
  background-color: E6E6FA;
}

.bg-\[\#E6E6FA\] {
  --tw-bg-opacity: 1;
  background-color: rgb(230 230 250 / var(--tw-bg-opacity));
}

.bg-\[\#191919\] {
  --tw-bg-opacity: 1;
  background-color: rgb(25 25 25 / var(--tw-bg-opacity));
}

.bg-\[\#232323\] {
  --tw-bg-opacity: 1;
  background-color: rgb(35 35 35 / var(--tw-bg-opacity));
}

.bg-white {
  --tw-bg-opacity: 1;
  background-color: rgb(255 255 255 / var(--tw-bg-opacity));
}

.bg-gradient-to-b {
  background-image: linear-gradient(to bottom, var(--tw-gradient-stops));
}

.from-\[\#304574\] {
  --tw-gradient-from: #304574 var(--tw-gradient-from-position);
  --tw-gradient-to: rgb(48 69 116 / 0) var(--tw-gradient-to-position);
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to);
}

.from-black {
  --tw-gradient-from: #000 var(--tw-gradient-from-position);
  --tw-gradient-to: rgb(0 0 0 / 0) var(--tw-gradient-to-position);
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to);
}

.via-\[\#304574\] {
  --tw-gradient-to: rgb(48 69 116 / 0)  var(--tw-gradient-to-position);
  --tw-gradient-stops: var(--tw-gradient-from), #304574 var(--tw-gradient-via-position), var(--tw-gradient-to);
}

.via-slate-950 {
  --tw-gradient-to: rgb(2 6 23 / 0)  var(--tw-gradient-to-position);
  --tw-gradient-stops: var(--tw-gradient-from), #020617 var(--tw-gradient-via-position), var(--tw-gradient-to);
}

.to-\[\#304574\] {
  --tw-gradient-to: #304574 var(--tw-gradient-to-position);
}

.to-slate-950 {
  --tw-gradient-to: #020617 var(--tw-gradient-to-position);
}

.p-2 {
  padding: 0.5rem;
}

.p-6 {
  padding: 1.5rem;
}

.p-8 {
  padding: 2rem;
}

.pl-12 {
  padding-left: 3rem;
}

.pl-32 {
  padding-left: 8rem;
}

.pl-5 {
  padding-left: 1.25rem;
}

.pl-64 {
  padding-left: 16rem;
}

.pl-72 {
  padding-left: 18rem;
}

.pl-80 {
  padding-left: 20rem;
}

.pr-12 {
  padding-right: 3rem;
}

.pr-5 {
  padding-right: 1.25rem;
}

.pr-64 {
  padding-right: 16rem;
}

.pt-20 {
  padding-top: 5rem;
}

.pt-32 {
  padding-top: 8rem;
}

.text-center {
  text-align: center;
}

.text-2xl {
  font-size: 1.5rem;
  line-height: 2rem;
}

.text-3xl {
  font-size: 1.875rem;
  line-height: 2.25rem;
}

.text-4xl {
  font-size: 2.25rem;
  line-height: 2.5rem;
}

.text-\[220px\] {
  font-size: 220px;
}

.text-lg {
  font-size: 1.125rem;
  line-height: 1.75rem;
}

.text-sm {
  font-size: 0.875rem;
  line-height: 1.25rem;
}

.text-xl {
  font-size: 1.25rem;
  line-height: 1.75rem;
}

.font-bold {
  font-weight: 700;
}

.font-semibold {
  font-weight: 600;
}

.uppercase {
  text-transform: uppercase;
}

.tracking-normal {
  letter-spacing: 0em;
}

.tracking-wide {
  letter-spacing: 0.025em;
}

.tracking-wider {
  letter-spacing: 0.05em;
}

.tracking-widest {
  letter-spacing: 0.1em;
}

.text-gray-300 {
  --tw-text-opacity: 1;
  color: rgb(209 213 219 / var(--tw-text-opacity));
}

.text-green-500 {
  --tw-text-opacity: 1;
  color: rgb(34 197 94 / var(--tw-text-opacity));
}

.text-orange-500 {
  --tw-text-opacity: 1;
  color: rgb(249 115 22 / var(--tw-text-opacity));
}

.text-white {
  --tw-text-opacity: 1;
  color: rgb(255 255 255 / var(--tw-text-opacity));
}

.line-through {
  text-decoration-line: line-through;
}

.shadow-2xl {
  --tw-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
  --tw-shadow-colored: 0 25px 50px -12px var(--tw-shadow-color);
  box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000), var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow);
}

.shadow-\[0_60px_50px_-15px_rgba\(0\2c 0\2c 0\2c 0\.3\)\] {
  --tw-shadow: 0 60px 50px -15px rgba(0,0,0,0.3);
  --tw-shadow-colored: 0 60px 50px -15px var(--tw-shadow-color);
  box-shadow: var(--tw-ring-offset-shadow, 0 0 #0000), var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow);
}

.transition-all {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 150ms;
}

.duration-500 {
  transition-duration: 500ms;
}

.hover\:text-white:hover {
  --tw-text-opacity: 1;
  color: rgb(255 255 255 / var(--tw-text-opacity));
}

.hover\:underline:hover {
  text-decoration-line: underline;
}

/* Sidebar */
.sidenav {
  background-color: #111;
  position: absolute;
  transition: width 0.5s;
  height: 100%;
}

/* Sidebar links container */
.hoverable-sidebar {
  width: 55px;
  overflow: hidden;
  transition: width 0.5s;
  white-space: nowrap; /* Prevent text from wrapping */
}

.sidenav:hover .hoverable-sidebar {
  width: 200px;
}

.sidenav:hover .hoverable-sidebar > .neger {
  opacity: 1;
}



/* Sidebar links */
.sidenav a {
  padding: 8px 8px 8px 19.5px;
  text-decoration: none;
  font-size: 20px;
  font-family: Arial, Helvetica, sans-serif;
  color: #818181;
  font-weight: 500;
  display: block;
  scale: 0.95;
  transition: 0.3s;

}

.neger {
  padding: 8px 8px 8px 28px;
  text-decoration: none;
  font-size: 23px;
  font-family: Arial, Helvetica, sans-serif;
  color: #fff;
  display: block;
  font-weight: 900;
  opacity: 0;
  transition: 0.3s;
}

.sidenav a:hover {
  color: #f1f1f1;
  scale: 1;


}

/* Adjust main content position */
#main {
  margin-left: 55px; /* Adjust as needed */
  transition: margin-left 0.5s;
}

</style>
