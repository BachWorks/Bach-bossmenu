<script lang="ts">
  import VisibilityProvider from './providers/VisibilityProvider.svelte';
  import ChooseStuff from './components/ChooseStuff.svelte';
  import { debugData } from './utils/debugData';

  debugData([
    {
      action: 'setVisible',
      data: true,
    },
  ]);
</script>

<main>
  <VisibilityProvider>
    <ChooseStuff />
  </VisibilityProvider>
</main>
