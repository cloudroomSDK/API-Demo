<template>
    <div>
        <Screen></Screen>
        <Media></Media>
        <VideoList></VideoList>
    </div>
</template>

<script>
import VideoList from "./videoList";
import Screen from "./screen";
import Media from "./media";
export default {
    components: {
        Screen,
        Media,
        VideoList,
    },
    data() {
        return {};
    },
};
</script>
