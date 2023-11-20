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
    showWithdrawInput = false;
    showInsertInput = false;
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
  <h2 class="header">Boss Menu</h2>
  <h1 class="header-under">({jobLabel})</h1>

  <div class="input flex flex-col space-y-1">
    {#each ["overview", "employees", "hire", "stash", "money"] as section}
      <button
        class="button relative overflow-hidden rounded-lg right-9 bg-[#0F0F0F] text-white px-1 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:bg-neutral-800 hover:text-white group"
        on:click={() => handleClick(section)}
      >
        {#if section === "overview"}
          <i class="fa-solid fa-circle-info text-xl text-violet-500" />
          <span
            class="absolute top-0 left-0 w-full h-full flex items-center justify-center opacity-100 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
            >Oversigt‎‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ <!-- Added så det står samme sted -->
          </span>
        {:else if section === "employees"}
          <i class="fa-solid fa-users text-xl text-violet-500" />
          <span
            class="absolute top-0 left-0 w-full h-full flex items-center justify-center opacity-100 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
            >Medarbejdere</span
          >
        {:else if section === "hire"}
          <i class="fa-solid fa-hand-holding text-xl text-violet-500" />
          <span
            class="absolute top-0 left-0 w-full h-full flex items-center justify-center opacity-100 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
            >Ansæt Person</span
          >
        {:else if section === "stash"}
          <i class="fa-solid fa-circle-user text-xl text-violet-500" />
          <span
            class="absolute top-0 left-0 w-full h-full flex items-center justify-center opacity-100 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
            >Personlig ‎ ‎ ‎ ‎ ‎ ‎</span
          >
        {:else if section === "money"}
          <i class="fa-solid fa-money-check-dollar text-xl text-violet-500" />
          <span
            class="absolute top-0 left-0 w-full h-full flex items-center justify-center opacity-100 group-hover:opacity-100 transition duration-300 bg-opacity-70 group-hover:bg-opacity-100"
            >Firma Kasse</span
          >
        {/if}
      </button>
    {/each}
  </div>

  {#if employeesShow}
    <div class="user-container">
      {#each $users as { name, empSource, gradeLabel, online, isboss }, index (gradeLabel)}
        <div class="mb-4 py-6 bg-neutral-700 p-6 rounded-lg shadow-lg">
          <div class="grid grid-cols-7 gap-1">
            <h3 class="text-2xl text-white mb-2 px-7">{online}</h3>
            <h3 class="text-base text-white">Navn: {name}.</h3>
            <h3 class="text-base text-white">CID: {empSource}.</h3>
            <h3 class="text-base text-white">Rang: {gradeLabel}.</h3>
            <h3 class="text-base text-white">Ledelse: {isboss}.</h3>

            {#if clientisBoss}
              <button
                class="button relative overflow-hidden text-violet-300 px-5 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:rotate-2 hover:text-white group"
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
            <div class="col-span-20 flex items-center justify-center space-x-1">
              <span class="text-green-500">I Byen</span>
              <span class="text-gray-400">|</span>
              <span class="text-red-500">Ikke I Byen</span>
            </div>

            <div class="col-span-2 flex items-center justify-start" />
          </div>

          {#if isModalOpen}
            <div
              class="fixed inset-0 bg-neutral-700 bg-opacity-25 flex items-center justify-center"
            >
              <div
                class="bg-[#0F0F0F] p-8 rounded shadow-lg text-white rounded-lg space-y-2"
              >
                <h2 class="text-xl mb-4">Vælg En Handling</h2>
                <button
                  on:click={() => handleAction(empSource)}
                  class="bg-red-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-red-500"
                >
                  <i class="fas fa-user-minus text-white" />
                  Fyr
                </button>

                <div>
                  <button
                    on:click={() => {
                      handleActionGrades(
                        empSource,
                        selectedGrade.id,
                        selectedGrade.navn
                      );
                    }}
                    class="bg-green-800 text-white px-5 py-2
                rounded transition duration-300 ease-in-out hover:bg-green-500"
                  >
                    <i class="fas fa-user-plus text-white" />
                    Skift Rang Til {selectedGrade.navn}
                  </button>
                  <label for="grades">Vælg Rang:</label>
                  <select
                    class="bg-[#0F0F0F] round-lg"
                    bind:value={selectedGrade}
                  >
                    {#each $gradeList as grade (grade.id)}
                      <option class="bg-[#0F0F0F] round-lg" value={grade}
                        >{grade.navn}</option
                      >
                    {/each}
                  </select>
                </div>

                <button
                  on:click={closeModal}
                  class="bg-neutral-600 text-white px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
                >
                  <i class="fas fa-x text-white" />
                  Annuller
                </button>
              </div>
            </div>
          {/if}
        </div>

        {#if index % 5 === 4}
          <div class="user-container" />
        {/if}
      {/each}
    </div>
  {:else if hireShow}
    <!--  Færdig -->
    <h1 class="text-2xl text-white mb-5 px-9 font-mono">SPILLERE I NÆRHEDEN</h1>

    <div class="user-container">
      {#each $nearByPlayers as { id, name, citizenid, sources, sourceplayer }, index (citizenid)}
        <div class="mb-4 py-6 bg-neutral-700 p-6 rounded-lg shadow-lg">
          <div class="grid grid-cols-7 gap-1">
            <h3 class="text-2xl text-white mb-2 px-9">ID: {id}</h3>
            <h3 class="text-base text-white">Navn: {name}.</h3>
            <h3 class="text-base text-white">CID: {citizenid}.</h3>

            {#if clientisBoss}
              <button
                class="button relative overflow-hidden text-violet-300 px-5 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:rotate-2 hover:text-white group"
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
                <h2 class="text-xl mb-4">Vælg En Handling</h2>
                <button
                  on:click={() => handleHire(id)}
                  class="bg-green-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-green-200"
                >
                  <i class="fas fa-user-plus text-white" />
                  Ansæt
                </button>
                <div>
                  <button
                    on:click={closeModal}
                    class="bg-neutral-600 text-white px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
                  >
                    <i class="fas fa-x text-white" />
                    Annuller
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
    <h2 class="text-3xl font-bold mb-4">Firma Konto</h2>
    <div class="flex items-center">
      <i class="fas fa-money-bill text-xl mr-2 animate-pulse" />
      <span class="text-2xl">${$firmaKasse}</span>
    </div>

    <h2 class="text-2xl font-bold mt-8 mb-4">Antal Medarbejdere</h2>
    <div class="flex items-center">
      <i class="fas fa-user-check text-xl mr-2 animate-pulse" />
      <span class="text-2xl">{amountWithJob} Medarbejder(e)</span>
    </div>
  {:else if moneyShow}
    <!-- Penge Side -->
    <h2 class="absolute text-3xl font-bold mb-4 mb-[40%]">FIRMA KASSE</h2>
    <div class="absolute flex items-center mb-[34%] ml-[-2.5%]">
      <i class="fas fa-money-bill text-xl mr-2 animate-pulse" />
      <span class="text-2xl">${$firmaKasse}</span>
    </div>

    <div class="absolute top-0 left-0 ml-[60%] mt-[2.5%]">
      <div class="flex items-center">
        <button
          class="ml-2 mr-2 bg-blue-500 text-white px-3 py-1 rounded transition duration-300 ease-in-out hover:bg-blue-700"
          on:click={toggleTransactions}
        >
          {#if showTransactions}
            Skjul Transaktioner
          {:else}
            Vis Transaktioner
          {/if}
        </button>
        <button
          on:click={() => {
            togglechooseHW();
            if (showTransactions) {
              toggleTransactions();
            }
          }}
          class="ml-2 mr-2 bg-blue-500 text-white px-3 py-1 rounded transition duration-300 ease-in-out hover:bg-blue-700"
        >
          Handlinger
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
          <h2 class="text-xl mb-4">Vælg En Handling</h2>
          <button
            on:click={() => toggleInput("insert")}
            class="bg-green-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-green-200"
          >
            Indsæt
          </button>
          <button
            on:click={() => toggleInput("withdraw")}
            class="bg-red-900 text-white px-5 py-2 mr-0 rounded transition duration-300 ease-in-out hover:bg-red-200"
          >
            Hæv
          </button>
          <div>
            <button
              on:click={togglechooseHW}
              class="bg-neutral-600 text-white px-4 py-2 mt-2 rounded transition duration-300 ease-in-out hover:bg-neutral-900"
            >
              Annuller
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
          <h2 class="text-xl mb-4">Indtast Beløb for Indsæt</h2>
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
              Annuller
            </button>
            <button
              on:click={() => {
                toggleBOTH();
                handleMoney("indseat");
              }}
              class="bg-green-500 text-[#FFF] px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-green-700"
            >
              Godkend
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
          <h2 class="text-xl mb-4">Indtast Beløb for Hæv</h2>
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
              Annuller
            </button>
            <button
              on:click={() => {
                toggleBOTH();
                handleMoney("heav");
              }}
              class="bg-green-500 text-[#FFF] px-4 py-2 mt-4 rounded transition duration-300 ease-in-out hover:bg-green-700"
            >
              Godkend
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
              <h3 class="text-base text-white">Navn: {name}.</h3>

              {#if clientisBoss}
                <button
                  class="button relative overflow-hidden text-violet-300 px-5 py-3 text-lg flex items-center space-x-1 transition-transform transform-gpu hover:scale-105 hover:rotate-2 hover:text-white group"
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
        class="bg-violet-500 text-white px-10 py-5 rounded-md transition duration-300 ease-in-out hover:shadow-xl hover:scale-105 transform focus:outline-none"
      >
        <i class="fas fa-box-open text-white mr-2" />
        Firma Lager
      </button>

      <button
      on:click={() => {
        handlePersonal("outfits");
      }}
        class="bg-violet-500 text-white px-10 py-5 rounded-md transition duration-300 ease-in-out hover:shadow-xl hover:scale-105 transform focus:outline-none"
      >
        <i class="fas fa-tshirt text-white mr-2" />
        Dine Outfits
      </button>
    </div>
  {/if}
</div>

<style>
  .container {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    align-content: center;
    justify-content: center;
    border-radius: 5px;
    width: 71%;
    height: 68%;
    font-size: 1.5vh;
    color: white;
    background-color: #0f0f0f;
    user-select: none;
    border-radius: 20px;
  }
  .header {
    font-size: large;
    position: absolute;
    color: white;
    top: 1%;
    left: 5%;
  }
  .header-under {
    font-size: large;
    position: absolute;
    color: white;
    top: 5%;
    left: 4.5%;
  }
  /* Andet */
  .input {
    position: absolute;
    display: flex;
    flex-direction: column;
    width: 200px;
    margin-top: -9%;
    margin-left: -78%;
    background-color: transparent;
    justify-content: center;
    border-radius: 30px;
  }

  .fa-solid {
    font-size: 165%;
  }
  .fas {
    font-size: 125%;
  }

  /* User */
  .user-container {
    margin-left: 15%;
    display: flex;
    flex-wrap: wrap;
    max-height: 480px;
    overflow-y: scroll;
    width: 1000px;
  }
  .user-container::-webkit-scrollbar {
    width: 0px; /* Gem Den Væk */
  }

  /* Money */
  .money-container {
    margin-left: 15%;
    margin-bottom: -7%;
    display: flex;
    flex-wrap: wrap;
    max-height: 500px;
    overflow-y: scroll;
    width: 1000px;
  }
  .money-container::-webkit-scrollbar {
    width: 0px; /* Gem Den Væk */
  }
</style>
