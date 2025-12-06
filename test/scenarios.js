import http from "k6/http"
import exec from "k6/execution"
import { sleep } from "k6"

export const options = {
  scenarios: {
    userCreation: {
      executor: "shared-iterations",
      exec: "userCreation",
      vus: 10,
      iterations: 1000,
      maxDuration: "1m",
    },
    userSleepCreation: {
      executor: "ramping-vus",
      exec: "userSleepCreation",
      startVUs: 0,
      stages: [
        { duration: "1s", target: 0 },
        { duration: "5s", target: 10 },
        { duration: "25s", target: 20 },
        { duration: "20s", target: 10 },
        { duration: "5s", target: 0 },
      ],
      gracefulRampDwon: "4s"
    },
    userFolloweeCreation: {
      executor: "per-vu-iterations",
      exec: "userFolloweeCreation",
      vus: 10,
      iterations: 500,
      maxDuration: "1m",
    },

  }
}

const HOST = "http://127.0.0.1:3000"
const HEADERS = {
  "Content-Type": "application/json"
}

export function setup() {
}

export function userCreation() {
  const newUser = {
    "name": `user-${exec.scenario.iterationInInstance}`
  }

  const response = http.post(`${HOST}/api/v1/users`, JSON.stringify(newUser), HEADERS)

  return { response }
}

export function userSleepCreation() {
  const now = new Date()
  const newSleep = {
    "start_time": now.toISOString()
  }

  http.post(`${HOST}/api/v1/users/${}/sleeps`, JSON.stringify(newSleep), HEADERS)

  sleep(1)

  return { response }
}

export function userFolloweeCreation() {
  const followerId = (exec.vu.idInInstance % 10) + 1
  const newFollowee = {
    "followed_id": exec.scenario.iterationInInstance + 1
  }

  const response = http.post(`${HOST}/api/v1/users/${followerId}/followees`, JSON.stringify(newFollowee), HEADERS)

  return { response }
}


