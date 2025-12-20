import React, { useState } from 'react';
import { Eye, EyeOff, Activity } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { api } from '../services/api';

interface LoginProps {
  onLogin: () => void;
}

export function Login({ onLogin }: LoginProps) {
  const [isSignup, setIsSignup] = useState(false);
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [nom, setNom] = useState('');
  const [prenom, setPrenom] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      if (isSignup) {
        // Mode inscription
        if (password !== confirmPassword) {
          setError('Les mots de passe ne correspondent pas');
          setLoading(false);
          return;
        }

        if (password.length < 6) {
          setError('Le mot de passe doit contenir au moins 6 caractères');
          setLoading(false);
          return;
        }

        await api.signup({
          username,
          password,
          email,
          nom,
          prenom,
        });

        setSuccess('Inscription réussie ! Vous pouvez maintenant vous connecter.');
        // Réinitialiser le formulaire
        setUsername('');
        setPassword('');
        setConfirmPassword('');
        setEmail('');
        setNom('');
        setPrenom('');
        // Passer en mode connexion après 2 secondes
        setTimeout(() => {
          setIsSignup(false);
          setSuccess('');
        }, 2000);
      } else {
        // Mode connexion
        await api.login({ username, password });
        onLogin();
      }
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-teal-50 flex items-center justify-center p-4">
      <div className="w-full max-w-[420px]">
        {/* Logo & Title */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-[#0B6FB0] rounded-2xl mb-4">
            <Activity className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-gray-900 mb-2">CHU Santé</h1>
          <p className="text-gray-600">Tableau de bord financier</p>
        </div>

        {/* Login Card */}
        <div className="card bg-white rounded-xl shadow-xl p-8">
          <h2 className="text-gray-900 mb-6">{isSignup ? 'Créer un compte' : 'Se connecter'}</h2>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
              {error}
            </div>
          )}

          {success && (
            <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-4">
              {success}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Nom et Prénom (Signup seulement) */}
            {isSignup && (
              <div className="grid grid-cols-2 gap-4">
                <Input
                  type="text"
                  label="Nom"
                  value={nom}
                  onChange={(e) => setNom(e.target.value)}
                  placeholder="Dupont"
                  required
                />
                <Input
                  type="text"
                  label="Prénom"
                  value={prenom}
                  onChange={(e) => setPrenom(e.target.value)}
                  placeholder="Jean"
                  required
                />
              </div>
            )}

            {/* Username */}
            <Input
              type="text"
              label="Nom d'utilisateur"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="jdupont"
              required
            />

            {/* Email (Signup seulement) */}
            {isSignup && (
              <Input
                type="email"
                label="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="jean.dupont@chu-sante.fr"
                required
              />
            )}

            {/* Password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Mot de passe {isSignup && '(min. 6 caractères)'}
              </label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="input w-full min-h-[44px] px-4 py-2 pr-12 border border-gray-300 rounded-lg focus:border-[#0B6FB0] focus:ring-4 focus:ring-blue-200 focus:outline-none"
                  placeholder="••••••••"
                  required
                  minLength={isSignup ? 6 : undefined}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 p-2"
                  aria-label={showPassword ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              {!isSignup && (
                <div className="flex justify-end mt-2">
                  <a href="#" className="text-sm text-[#0B6FB0] hover:text-[#095a8f]">
                    Mot de passe oublié ?
                  </a>
                </div>
              )}
            </div>

            {/* Confirm Password (Signup seulement) */}
            {isSignup && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Confirmer le mot de passe
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="input w-full min-h-[44px] px-4 py-2 border border-gray-300 rounded-lg focus:border-[#0B6FB0] focus:ring-4 focus:ring-blue-200 focus:outline-none"
                    placeholder="••••••••"
                    required
                  />
                </div>
              </div>
            )}

            {/* Remember me (Login seulement) */}
            {!isSignup && (
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="remember"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="w-5 h-5 text-[#0B6FB0] border-gray-300 rounded focus:ring-[#0B6FB0] focus:ring-2"
                />
                <label htmlFor="remember" className="ml-3 text-sm text-gray-700">
                  Se souvenir de moi
                </label>
              </div>
            )}

            {/* Submit button */}
            <Button
              type="submit"
              variant="primary"
              size="lg"
              fullWidth
              loading={loading}
              className="mt-6"
            >
              {isSignup ? 'Créer mon compte' : 'Se connecter'}
            </Button>
          </form>

          {/* Toggle Signup/Login */}
          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">
              {isSignup ? 'Vous avez déjà un compte ?' : "Vous n'avez pas de compte ?"}{' '}
              <button
                type="button"
                onClick={() => {
                  setIsSignup(!isSignup);
                  setError('');
                  setSuccess('');
                }}
                className="text-[#0B6FB0] hover:text-[#095a8f] font-medium"
              >
                {isSignup ? 'Se connecter' : 'Créer un compte'}
              </button>
            </p>
          </div>

          {/* Help text */}
          {!isSignup && (
            <p className="mt-4 text-center text-sm text-gray-600">
              Besoin d'aide ? Contactez le{' '}
              <a href="#" className="text-[#0B6FB0] hover:text-[#095a8f]">
                support technique
              </a>
            </p>
          )}
        </div>

        {/* Footer */}
        <p className="mt-6 text-center text-sm text-gray-500">
          © 2025 CHU Santé. Tous droits réservés.
        </p>
      </div>
    </div>
  );
}