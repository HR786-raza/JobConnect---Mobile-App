// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI",
  authDomain: "jobconnect-12.firebaseapp.com",
  projectId: "jobconnect-12",
  storageBucket: "jobconnect-12.firebasestorage.app",
  messagingSenderId: "406743820372",
  appId: "1:406743820372:web:609254f42027bec3cc65c1",
  measurementId: "G-1FPEYYKJRR"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);