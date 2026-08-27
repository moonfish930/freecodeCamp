import { Router } from "express";
import { authenticate } from "../middleware/authenticate.js";
import { authorizeModification } from "../middleware/authorize.js";
import {
  getWatchlist,
  addMovie,
  updateMovie,
  deleteMovie,
} from "../utils/db.js";

const router = Router();

// Aplicar autenticación a todas las rutas de la watchlist
router.use(authenticate);

// GET /api/watchlist/:userId
router.get("/:userId", (req, res) => {
  // Convertir a número o string según como lo maneje getWatchlist en db.js
  // getWatchlist llama a findById que busca u.id === id
  const userId = isNaN(req.params.userId) ? req.params.userId : Number(req.params.userId);
  const watchlist = getWatchlist(userId);

  if (watchlist === null) {
    return res.status(404).json({ error: "User not found" });
  }

  return res.status(200).json(watchlist);
});

// POST /api/watchlist/:userId/movies
router.post("/:userId/movies", authorizeModification, (req, res) => {
  const userId = isNaN(req.params.userId) ? req.params.userId : Number(req.params.userId);
  const movie = addMovie(userId, req.body);
  return res.status(201).json(movie);
});

// PUT /api/watchlist/:userId/movies/:movieId
router.put("/:userId/movies/:movieId", authorizeModification, (req, res) => {
  const userId = isNaN(req.params.userId) ? req.params.userId : Number(req.params.userId);
  const movieId = Number(req.params.movieId);
  const updatedMovie = updateMovie(userId, movieId, req.body);
  return res.status(200).json(updatedMovie);
});

// DELETE /api/watchlist/:userId/movies/:movieId
router.delete("/:userId/movies/:movieId", authorizeModification, (req, res) => {
  const userId = isNaN(req.params.userId) ? req.params.userId : Number(req.params.userId);
  const movieId = Number(req.params.movieId);
  deleteMovie(userId, movieId);
  return res.status(200).json({ message: "Movie removed successfully." });
});

export default router;