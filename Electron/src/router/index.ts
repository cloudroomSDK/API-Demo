import { createRouter, createWebHashHistory } from "vue-router";

const routes = [
  { path: "/", redirect: "/login" },
  { path: "/layout", component: () => import("@/views/layout/index.vue") },
  { path: "/login", component: () => import("@/views/login.vue") },
];


const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
